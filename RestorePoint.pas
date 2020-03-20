unit RestorePoint;
interface
uses Windows, SysUtils;
const
  { restore point types }
  APPLICATION_INSTALL = 0;
  APPLICATION_UNINSTALL = 1;
  DEVICE_DRIVER_INSTALL = 10;
  MODIFY_SETTINGS = 12;
  CANCELLED_OPERATION = 13;
  { event types }
  BEGIN_SYSTEM_CHANGE = 100;
  END_SYSTEM_CHANGE = 101;
  { other stuff }
  MAX_DESC = 256;

type
  int64 = comp; { comment this if you are on a Delphi that supports int64 }
  restoreptinfo = packed record
    dwEventType: DWord;
    dwRestorePtType: DWord;
    llSequenceNumber: int64;
    szDescription: array[0..max_desc] of widechar;
  end;
  prestoreptinfo = ^restoreptinfo;
  statemgrstatus = packed record
    nStatus: DWord;
    llSequenceNumber: int64;
  end;
  pstatemgrstatus = ^statemgrstatus;
  set_func = function(restptinfo: prestoreptinfo;
    status: pstatemgrstatus): boolean; stdcall;
  remove_func = function(dwRPNum: DWord): DWord; stdcall;

var
  DLLHandle: THandle;
  set_restore: set_func;
  remove_restore: remove_func;

function begin_restore(var seqnum: int64; instr: widestring): DWord;
function end_restore(seqnum: int64): DWord;
function cancel_restore(seqnum: int64): integer;
function error_report(inerr: integer): string;

implementation

function begin_restore(var seqnum: int64; instr: widestring): DWord;
{ starts a restore point }
var
  r_point: restoreptinfo;
  smgr: statemgrstatus;
  fret: boolean;
  retval: integer;
begin
  retval := 0;
  fillchar(r_point, sizeof(r_point), 0);
  fillchar(smgr, sizeof(smgr), 0);
  r_point.dwEventType := BEGIN_SYSTEM_CHANGE;
  r_point.dwRestorePtType := APPLICATION_INSTALL;
  move(instr[1], r_point.szDescription, max_desc);
  r_point.llSequenceNumber := 0;
  fret := set_restore(@r_point, @smgr);
  if fret = false then
    retval := smgr.nStatus;
  seqnum := smgr.llSequenceNumber;
  begin_restore := retval;
end;

function end_restore(seqnum: int64): DWord;
{ ends restore point }
var
  r_point: restoreptinfo;
  smgr: statemgrstatus;
  fret: boolean;
  retval: integer;
begin
  retval := 0;
  fillchar(r_point, sizeof(r_point), 0);
  fillchar(smgr, sizeof(smgr), 0);
  r_point.dwEventType := END_SYSTEM_CHANGE;
  r_point.llSequenceNumber := seqnum;
  fret := set_restore(@r_point, @smgr);
  if fret = false then
    retval := smgr.nStatus;
  end_restore := retval;
end;

function cancel_restore(seqnum: int64): integer;
{ cancels restore point in progress}
var
  r_point: restoreptinfo;
  smgr: statemgrstatus;
  retval: integer;
  fret: boolean;
begin
  retval := 0;
  r_point.dwEventType := END_SYSTEM_CHANGE;
  r_point.dwRestorePtType := CANCELLED_OPERATION;
  r_point.llSequenceNumber := seqnum;
  fret := set_restore(@r_point, @smgr);
  if fret = false then
    retval := smgr.nStatus;
  cancel_restore := retval;
end;

function error_report(inerr: integer): string;
begin
{  case inerr of
    ERROR_SUCCESS: error_report := SERROR_SUCCESS;
    ERROR_BAD_ENVIRONMENT: error_report := SERROR_BAD_ENVIRONMENT;
    ERROR_DISK_FULL: error_report := SERROR_DISK_FULL;
    ERROR_FILE_EXISTS: error_report := SERROR_FILE_EXISTS;
    ERROR_INTERNAL_ERROR: error_report := SERROR_INTERNAL_ERROR;
    ERROR_INVALID_DATA: error_report := SERROR_INVALID_DATA;
    ERROR_SERVICE_DISABLED: error_report := SERROR_SERVICE_DISABLED;
    ERROR_TIMEOUT: error_report := SERROR_TIMEOUT;
  else
    error_report := IntToStr(inerr);
  end;}
end;

initialization
  { find library functions and enable them }
  DLLHandle := LoadLibraryW('SRCLIENT.DLL');
  if DLLHandle <> 0 then
  begin
    @set_restore := GetProcAddress(DLLHandle, 'SRSetRestorePointW');
    if @set_restore = nil then
    begin
      raise Exception.Create('Did not find SRSetRestorePointW');
      halt(1);
    end;
    @remove_restore := GetProcAddress(DLLHandle, 'SRRemoveRestorePoint');
    if @remove_restore = nil then
    begin
      raise Exception.Create('Did not find SRRemoveRestorePoint');
      halt(1);
    end;
  end
  else
  begin
    raise Exception.Create('System Restore Interface Not Present.');
    halt(1);
  end;

finalization
  { release library }
  FreeLibrary(DLLHandle);
end.

