unit RegFilesCollection;
interface

uses Windows, SysUtils, Classes, Registry, Dialogs, Psapi, tlhelp32, IniFiles,
  Settings;

const
  SysHiveList = 'System\CurrentControlSet\Control\hivelist';

function GetFileSize(FileName: string): int64; //64 bit files

function GetHiveList: boolean;
function GetKeyName(KeyHandler: HKEY): string;
procedure CreateWinNTProcessList(List: TstringList);

var
  RegKeysNames: TStringList;
  RegKeysList: TStringList;
  HivePath: TStringList;
  AllSize: int64;
  NewAllFilesSize: int64;

implementation
var
  DiskList: TStringList;
  BeehiveCount: integer;

  errorBuf: array[0..80] of WideChar;
  lastError: DWORD;

function GetFileSize(FileName: string): int64; //64 bit files
var
  SearchRec: TSearchRec;
begin
  Result := 0;
  if FindFirst(ExpandFileName(FileName), faAnyFile, SearchRec) = 0 then
    Result := (SearchRec.FindData.nFileSizeHigh shl 32) + SearchRec.FindData.nFileSizeLow;
  FindClose(SearchRec);
end;

//http://expert.delphi.int.ru/question/1713/

procedure GetDosDevices;
var
  Device: char;
  Volume: string;
  lpQuery: array[0..MAXCHAR - 1] of char;
  FInfo: string;
begin
  for Device := 'A' to 'Z' do
    if GetDriveType(PAnsiChar(string(Device + ':\'))) = DRIVE_FIXED then
    begin
      Volume := Device + ':' + #0;
      QueryDosDevice(PChar(Volume), @lpQuery[0], MAXCHAR);
      Volume[3] := '\';
      FInfo := string(lpQuery);
      DiskList.Values[FInfo] := Volume;
    end;
end;


function GetHiveList: boolean;
var
  Registry: TRegistry;
  KeyNum: integer;
  KeyNameSub, KeyName, KeyValue: string;
  FilePath: string;
  FileSize: longint;
  SaveKey: HKEY;
begin
  Result := false;
  Registry := TRegistry.Create;
  try
    GetDosDevices;
    Registry.RootKey := HKEY_LOCAL_MACHINE;

    Registry.Access := KEY_WOW64_64KEY or KEY_ALL_ACCESS;

    if not Registry.OpenKeyReadOnly(SysHiveList) then AddToLog('Can''t access to system registy files list.')
    else
    begin
      Registry.GetValueNames(RegKeysNames);

      AllSize := 0;
      BeehiveCount := 0;
      for KeyNum := 0 to RegKeysNames.Count - 1 do
      begin
        KeyName := GetWordString(2, RegKeysNames.Strings[KeyNum], ['\']);
        KeyNameSub := GetWordString(3, RegKeysNames.Strings[KeyNum], ['\']);
        KeyValue := Registry.ReadString(RegKeysNames.Strings[KeyNum]);

        if KeyValue <> '' then
        begin
          FilePath := TrimRight(DiskList.Values[Copy(KeyValue, 0, GetWordStringPos(3, KeyValue, ['\']) - 2)])
          + Copy(KeyValue, GetWordStringPos(3, KeyValue, ['\']), Length(KeyValue));

          FileSize := GetFileSize(FilePath);
          AllSize := AllSize + FileSize;
          Inc(BeehiveCount);

          HivePath.AddObject(FilePath, TObject(FileSize));

          SaveKey := 0;
          if AnsiUpperCase(KeyName) = 'USER' then SaveKey := HKEY_USERS;
          if AnsiUpperCase(KeyName) = 'MACHINE' then SaveKey := HKEY_LOCAL_MACHINE;
          if SaveKey <> 0 then  RegKeysList.AddObject(KeyNameSub, TObject(SaveKey));

        end;
      end;
      result := true;
    end;
  finally
    Registry.Destroy;
  end;
end;


function GetKeyName(KeyHandler: HKEY): string;
begin
  Result := '';
  if KeyHandler = HKEY_CLASSES_ROOT then Result := 'HKEY_CLASSES_ROOT'
  else
    if KeyHandler = HKEY_CURRENT_USER then Result := 'HKEY_CURRENT_USER'
    else
      if KeyHandler = HKEY_LOCAL_MACHINE then Result := 'HKEY_LOCAL_MACHINE'
      else
        if KeyHandler = HKEY_LOCAL_MACHINE then Result := 'HKEY_LOCAL_MACHINE'
        else
          if KeyHandler = HKEY_USERS then Result := 'HKEY_USERS';
end;


procedure CreateWinNTProcessList(List: TstringList);
var
  PIDArray: array[0..1023] of DWORD;
  cb: DWORD;
  I: Integer;
  ProcCount: Integer;
  hMod: HMODULE;
  hProcess: THandle;
  ModuleName: array[0..300] of Char;
begin
  if List = nil then Exit;
  EnumProcesses(@PIDArray, SizeOf(PIDArray), cb);
  ProcCount := cb div SizeOf(DWORD);
  for I := 0 to ProcCount - 1 do
  begin
    hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or
      PROCESS_VM_READ,
      False,
      PIDArray[I]);
    if (hProcess <> 0) then
    begin
      EnumProcessModules(hProcess, @hMod, SizeOf(hMod), cb);
      GetModuleFilenameEx(hProcess, hMod, ModuleName, SizeOf(ModuleName));
      List.Add(ModuleName);
      CloseHandle(hProcess);
    end;
  end;
end;

initialization
  HivePath := TStringList.Create;
  DiskList := TStringList.Create;
  RegKeysNames := TStringList.Create;
  RegKeysList := TStringList.Create;
finalization
  HivePath.Destroy;
  DiskList.Destroy;
  RegKeysNames.Destroy;
  RegKeysList.Destroy;
end.

