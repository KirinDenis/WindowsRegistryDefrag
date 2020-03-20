unit Defrag;
interface
uses Windows, Forms, Classes, SysUtils, Settings, RegFilesCollection, Messages;

const
  WM_DefragStart = WM_USER + $101;
  WM_DefragError = WM_USER + $102;
  WM_DefragProcess = WM_USER + $102;
  WM_DefragComplete = WM_USER + $103;


type

  TDefragFileMode = set of (DMTest, DMRestore, DMDefrag);

  TDefragFileThread = class(TThread)
  protected
    procedure Execute; override;
  public
    CriticalSection: TRTLCriticalSection;
    Mode: TDefragFileMode;
    fKey: HKEY;
    fSubKey: string;
    RegFileName: string;
    NewFileName: string;
    BackupFileName: string;
    FileSize: dword;
    NewFileSize: dword;
  end;

//Index at Hive list
function TestRegFile(Index: integer; MessageHandler: dword; var RegFileSize, RegFileNewSize: dword): dword;
function DefragRegFile(Index: integer; MessageHandler: dword; var RegFileSize, RegFileNewSize: dword): dword;
function DefragAllFiles: dword;


implementation
uses
  TestRegistry;
type
  TThreadNameInfo = record
    FType: LongWord; // must be 0x1000
    FName: PChar; // pointer to name (in user address space)
    FThreadID: LongWord; // thread ID (-1 indicates caller thread)
    FFlags: LongWord; // reserved for future use, must be zero
  end;


procedure TDefragFileThread.Execute;
type
  TThreadInfo = record
    FType: LongWord;
    FName: PChar;
    FThreadID: LongWord;
    FFlags: LongWord;
  end;
var
  ThreadInfo: TThreadInfo;
  samDesired: REGSAM;
  dwDisposition: cardinal;
  fKeyToSave: HKEY;
  result: dword;
begin

  //put thread name to windows -------------------------------------------------
  ThreadInfo.FType := $1000;
  ThreadInfo.FName := 'RegistryDefragThread';
  ThreadInfo.FThreadID := $FFFFFFFF;
  ThreadInfo.FFlags := 0;
  try
    RaiseException($406D1388, 0, sizeof(ThreadInfo) div sizeof(LongWord), @ThreadInfo);
  except
  end;

  FileSize := GetFileSize(RegFileName);

  if FileExists(NewFileName) then DeleteFile(NewFileName);

  //All mode enter to this section ---------------------------------------------
  //Debug

  if Is64bitOS then samDesired := KEY_ALL_ACCESS or KEY_WOW64_64KEY
  else samDesired := KEY_QUERY_VALUE;

  RegCreateKeyEx(fKey, PChar(fSubKey), 0, nil, REG_OPTION_BACKUP_RESTORE, samDesired, nil, fKeyToSave, @dwDisposition);

  RegFlushKey(fKey);

  RegSaveKey(fKeyToSave, Pchar(NewFileName), nil);

  RegCloseKey(fKeyToSave);


  if DMDefrag in Mode then
  begin
    if FileExists(BackupFileName) then DeleteFile(BackupFileName);
    RegReplaceKey(FKey, PChar(FSubKey), PChar(NewFileName), PChar(BackupFileName));
    NewFileSize := GetFileSize(BackupFileName);
  end
 else
  NewFileSize := GetFileSize(NewFileName);

  //Debug
 // NewFileSize := FileSize - Random($FFF) ;
 // Sleep(FileSize div 4000);


  DeleteFile(NewFileName);

  Terminate;
end;
//------------------------------------------------------------------------------

function TestRegFile(Index: integer; MessageHandler: dword; var RegFileSize, RegFileNewSize: dword): dword;
var
  CriticalSection: TRTLCriticalSection;
  DefragFileThread: TDefragFileThread;
  ThreadTime: dword;
begin
  SendMessage(MessageHandler, WM_DefragStart, 0, 0);
  InitializeCriticalSection(CriticalSection);

  DefragFileThread := TDefragFileThread.Create(True);
  DefragFileThread.CriticalSection := CriticalSection;
  DefragFileThread.fKey := HKEY(RegKeysList.Objects[Index]);
  DefragFileThread.fSubKey := RegKeysList[Index];
  DefragFileThread.RegFileName := HivePath[Index];
  DefragFileThread.NewFileName := HivePath[Index] + '_temp';
  DefragFileThread.BackupFileName := HivePath[Index] + '_backup';
  DefragFileThread.Mode := [DMTest];

  DefragFileThread.Resume;

  ThreadTime := GetTickCount;
  while not DefragFileThread.Terminated do
  begin
    if GetTickCount > ThreadTime + 500 then
    begin
      SendMessage(MessageHandler, WM_DefragProcess, Index, 0);
      ThreadTime := GetTickCount;
    end;
    Application.ProcessMessages;    
  end;

  NewAllFilesSize := NewAllFilesSize + Trunc(DefragFileThread.NewFileSize);

  RegFileSize := DefragFileThread.FileSize;
  RegFileNewSize := DefragFileThread.NewFileSize;

  DefragFileThread.Free;

  DeleteCriticalSection(CriticalSection);

  SendMessage(MessageHandler, WM_DefragComplete, 0, 0);
end;
//------------------------------------------------------------------------------
function DefragRegFile(Index: integer; MessageHandler: dword; var RegFileSize, RegFileNewSize: dword): dword;
var
  CriticalSection: TRTLCriticalSection;
  RestorePoint: Comp;
  DefragFileThread: TDefragFileThread;
  ThreadTime: dword;
begin
  SendMessage(MessageHandler, WM_DefragStart, 0, 0);
  InitializeCriticalSection(CriticalSection);

  DefragFileThread := TDefragFileThread.Create(True);
  DefragFileThread.CriticalSection := CriticalSection;
  DefragFileThread.fKey := HKEY(RegKeysList.Objects[Index]);
  DefragFileThread.fSubKey := RegKeysList[Index];
  DefragFileThread.RegFileName := HivePath[Index];
  DefragFileThread.NewFileName := HivePath[Index] + '_temp';
  DefragFileThread.BackupFileName := HivePath[Index] + '_backup';
  DefragFileThread.Mode := [DMDefrag];

  DefragFileThread.Resume;

  ThreadTime := GetTickCount;

  while not DefragFileThread.Terminated do
  begin
    if GetTickCount > ThreadTime + 100 then
    begin
      SendMessage(MessageHandler, WM_DefragProcess, Index, 0);
      ThreadTime := GetTickCount;
    end;
    Application.ProcessMessages;
  end;

  NewAllFilesSize := NewAllFilesSize + Trunc(DefragFileThread.NewFileSize);

  RegFileSize := DefragFileThread.FileSize;
  RegFileNewSize := DefragFileThread.NewFileSize;

  DefragFileThread.Free;

  DeleteCriticalSection(CriticalSection);

  SendMessage(MessageHandler, WM_DefragComplete, 0, 0);
end;

function DefragAllFiles: dword;
var
  i: integer;
  s, ns: dword;
begin


  NewAllFilesSize := 0;

  for i := 0 to HivePath.Count - 1 do
  begin
    DefragRegFile(i, 0, s, ns);
  end;



end;



end.

