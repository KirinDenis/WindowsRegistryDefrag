unit Settings;
interface
uses SysUtils, Classes, Masks, Windows;
const
  //URLs

  ProductHomePage: string = 'http://dci-software.com/defrag.html';
  ProductBuyPage: string = 'http://dci-software.com/defrag.html';
  ProductSupportPage: string = 'http://dci-software.com/defrag.html';


  ConfigsFolder: string = '\Settings\';
  WorkFolder: string = '';

  GeneralCfg = 'RegDefrag.ini';
  LanguageCfg = 'language.ini';

  // DB Config
  //open query in new window
  //0 - yes
  //1 - no
  //2 - unknow, need to be setupet by user
  QueryInNewWindow: byte = 2; //2 by default for clean system

  DebugMode: boolean = false;
  RegisterResult: integer = $FF;

  clrBaseGreen = $355300;
  clrBaseRed = $3401D9;
  clrBaseMarron = $262343;
  clrBaseWhite = $E9F5FB;

  clrDarkGreen = $9CB000;
  clrDarkRed = $321BF9;
  clrDarkNavy = $815A01;

  clrNormalMarron = $ADA8BD;
  clrNormalNavy = $D69701;
  clrNormalBlue = $FBDDA6;
  clrNormalGreen = $C2CF9B;
  clrNormalYellow = $2ED6E8;
  clrNormalRed = $6682FF; // $FF8266;
  clrNormalLYellow = $1FC6FF;
  clrNormalLPink = $C4D8F7;
  clrNormalPink = $AA6FF6;

  clrLightMarron = $D3D1DD;
  clrLightNavy = $E8CEB0;
  clrLightBlue = $EFEFDF;
  clrLightGreen = $DFE9DC;
  clrLightYellow = $27E8FC;
  clrLightRed = $BAADFD;
  clrLightLYellow = $9AF7FF;
  clrLightLPink = $AEE6F7;
  clrLightPink = $D3B6FB;

  KEY_WOW64_32KEY = $200;
  KEY_WOW64_64KEY = $100;
  

procedure ResetConfig;

// key<[#9],[' '],['=']>value
function DotStringToInteger(s: string): integer;
function GetKeyValue(Value: string; Number: integer): string;

function GetMKey(Key: string): string;
function GetMNextKey(Key: string): string;
function SetMKey(Key, Value: string): boolean;

function GetLKey(Key: string): string; overload;
function GetLKey(Key, Caption: string): string; overload;
function GetLNextKey(Key: string): string;

procedure AddToLog(Text: string);
procedure AddToReport(Text: string);

function ExpandEnvironmentPath(Source: string): string;

function CheckFileName(FileName: string): string;

function KillDoubleSlash(Text: string): string;
function KillSpace(Text: string): string;
function KillSpace2(Text: string): string;
function KillZero(Text: string): string;

function GetWordStringPos(const Index: Integer; const s: string; const Delimetr: TSysCharSet): Integer;
function GetWordString(Index: integer; const s: string; const Delimetr: TSysCharSet): string;

procedure GetPrivilegeNames(Strings: TStrings);
function SetPrivileges: boolean;
function EnablePrivileges(const NamePrivilege: string): Boolean;

function StringToDotString(SourceStr: string): string;

function Is64bitOS: Boolean;

var
  LanguagesFolders: array[0..40] of string[20];
  LanguagesCount: integer = -1;
  CurrentLanguage: integer;
  RegistCount: integer = 0;
  MList: TStringList = nil;
  LList: TStringList = nil;

implementation
var
  FindCount: integer;

  errorBuf: array[0..80] of WideChar;
  lastError: DWORD;

procedure ResetConfig;
begin
  FreeAndNil(MList);
  FreeAndNil(LList);
end;

function DotStringToInteger(s: string): integer;
var
  s2: string;
  i: integer;
begin
  s2 := '';
  for i := 1 to length(s) do
    if s[i] <> ',' then s2 := s2 + s[i];
  Result := StrToIntDef(s2, 0);
end;


procedure AddToLog(Text: string);
var
  F: TextFile;
begin
  try
    if not DebugMode then Exit;
    AssignFile(F, WorkFolder + '\report.txt');
    if FileExists(WorkFolder + '\report.txt') then Append(F)
    else Rewrite(F);
    WriteLn(F, DateTimeToStr(Now) + #9 + Text);
    CloseFile(F);
  except
  end;
end;

procedure AddToReport(Text: string);
var
  F: TextFile;
begin
  try
    AssignFile(F, WorkFolder + '\wizardreport.txt');
    if FileExists(WorkFolder + '\wizardreport.txt') then Append(F)
    else Rewrite(F);
    WriteLn(F, DateTimeToStr(Now) + #9 + Text);
    CloseFile(F);
  except
  end;
end;


function SpaceChar(c: char): boolean;
begin
  SpaceChar := false;
  case c of
    ' ', '=', #9: SpaceChar := true;
  end;
end;

function SpaceChar2(c: char): boolean;
begin
  SpaceChar2 := false;
  case c of
    ' ', '=', #9, '.', '/': SpaceChar2 := true;
  end;
end;


function ExpandEnvironmentPath(Source: string): string;
var
  Destination: string;
begin
  Result := Source;
  SetLength(Destination, 1025);
  ZeroMemory(@Destination[1], 1024);
  if ExpandEnvironmentStrings(pointer(Source), @Destination[1], 1024) > 0 then
    Result := string(PChar(Destination));
end;

function KillDoubleSlash(Text: string): string;
begin
  result := Text;
  repeat
    if Pos('\\', result) > 0 then
    begin
      Result := Copy(Result, 1, pos('\\', Result) - 1) + '\' +
        Copy(Result, pos('\\', Result) + 2, length(Result));
    end;
  until Pos('\\', Result) = 0;
end;


function CheckFileName(FileName: string): string;
var
  F: TextFile;
  count: integer;
begin
{$I-}
  try
    AssignFile(F, ExpandEnvironmentPath('%Temp%') + '\' + ExtractFileName(FileName));
    Rewrite(F);
    CloseFile(F);

    DeleteFile(PChar(ExpandEnvironmentPath('%Temp%') + '\' + ExtractFileName(FileName)));
  except
    count := 1;
    repeat
      FileName := ExtractFileDir(FileName) + '\NoName ' + IntToStr(Count) + ExtractFileExt(FileName);
      inc(count);
    until not FileExists(FileName);
  end;
 //----------- TODO: Maybe diferent place
  if not DirectoryExists(ExtractFileDir(FileName)) then
    ForceDirectories(ExtractFileDir(FileName));
  result := FileName;

end;
//------------------------------------------------------------------------------

function KillSpace(Text: string): string;
var
  Count: integer;
  NewText: string;
begin
  if Text = '' then Exit;
  NewText := '';
  for count := 1 to length(Text) do
    if not (SpaceChar(Text[Count])) then break;

  if SpaceChar(Text[1]) then Text := Copy(Text, Count, length(Text));

  if Text = '' then Exit;
  NewText := '';
  Count := 1;
  repeat
    if (Count > 1)
      and
      (SpaceChar(Text[Count]))
      and
      (SpaceChar(Text[Count - 1])) then
    else NewText := NewText + Text[Count];
    inc(Count);
  until Count > length(Text);
  if length(NewText) > 0 then
    if SpaceChar(NewText[length(NewText)]) then SetLength(NewText, length(NewText) - 1);

  if Pos('/ln', NewText) > 0 then
  begin
    repeat
      NewText := Copy(NewText, 1, pos('/ln', NewText) - 1) + #$0D + #$0A
        + Copy(NewText, pos('/ln', NewText) + 3, length(NewText));
    until Pos('/ln', NewText) = 0;
  end;
  result := NewText;
end;

function KillSpace2(Text: string): string;
var
  Count: integer;
  NewText: string;
begin
  if Text = '' then Exit;
  NewText := '';
  for count := 1 to length(Text) do
    if not (SpaceChar2(Text[Count])) then break;

  if SpaceChar2(Text[1]) then Text := Copy(Text, Count, length(Text));

  if Text = '' then Exit;
  NewText := '';
  Count := 1;
  repeat
    if (Count > 1)
      and
      (SpaceChar2(Text[Count]))
      and
      (SpaceChar2(Text[Count - 1])) then
    else NewText := NewText + Text[Count];
    inc(Count);
  until Count > length(Text);
  if length(NewText) > 0 then
    if SpaceChar2(NewText[length(NewText)]) then SetLength(NewText, length(NewText) - 1);

  if Pos('/ln', NewText) > 0 then
  begin
    repeat
      NewText := Copy(NewText, 1, pos('/ln', NewText) - 1) + #$0D + #$0A
        + Copy(NewText, pos('/ln', NewText) + 3, length(NewText));
    until Pos('/ln', NewText) = 0;
  end;
  result := NewText;
end;

//------------------------------------------------------------------------------

function GetPos(Text: string): integer;
var
  Pos1, Pos2, Pos3, Pos4: integer;
begin
  Pos1 := pos(#9, Text);
  Pos2 := pos(' ', Text);
  Pos3 := pos('=', Text);
  Pos4 := pos(':', Text);
  if Pos1 = 0 then Pos1 := length(Text);
  if Pos2 = 0 then Pos2 := length(Text);
  if Pos3 = 0 then Pos3 := length(Text);
  if Pos4 = 0 then Pos4 := length(Text);
  if Pos1 > Pos2 then Pos1 := Pos2;
  if Pos1 > Pos3 then Pos1 := Pos3;
  if Pos1 > Pos4 then Pos1 := Pos4;
  GetPos := Pos1;
end;

function KillZero(Text: string): string;
var
  s1, s2: string;
begin
  repeat
    if pos(#0, Text) <> 0 then
    begin
      s1 := copy(Text, 1, pos(#0, Text) - 1);
      s2 := copy(Text, pos(#0, Text) + 1, length(Text));
      text := s1 + s2;
    end
    else
      break;
  until false;
  result := text;
end;
//------------------------------------------------------------------------------

function FindKey(List: TStringList; Key: string): integer;
var
  Count: integer;
begin
  FindCount := -1;
  FindKey := -1;
  for Count := 0 to List.Count - 1 do
    if (MatchesMask(List[Count], Format('%s *', [Key])))
      or
      (MatchesMask(List[Count], Format('%s%s*', [Key, #9])))
      or
      (MatchesMask(List[Count], Format('%s=*', [Key]))) then
    begin
      FindKey := Count;
      FindCount := Count;
      Break;
    end;
end;
//------------------------------------------------------------------------------

function FindNextKey(List: TStringList; Key: string): integer;
var
  Count: integer;
begin
  FindNextKey := -1;
  if FindCount = -1 then Exit;
  inc(FindCount);
  for Count := FindCount to List.Count - 1 do
    if (MatchesMask(List[Count], Format('%s *', [Key])))
      or
      (MatchesMask(List[Count], Format('%s%s*', [Key, #9])))
      or
      (MatchesMask(List[Count], Format('%s=*', [Key]))) then
    begin
      FindNextKey := Count;
      Break;
    end;
end;
//------------------------------------------------------------------------------

function FindValuePos(CfgString: string): integer;
begin
  FindValuePos := -1;
  if Length(CfgString) < 3 then Exit;
  FindValuePos := GetPos(CfgString);
end;
//------------------------------------------------------------------------------

function SetKey(ConfigFileName, Key, Value: string): boolean;
var
  Handle, Index: integer;
  SList: TStringList;
begin
  SetKey := false;
  if not (FileExists(ConfigFileName)) then
  begin
    Handle := FileCreate(ConfigFileName);
    if fmOpenWrite < 0 then Exit;
    FileClose(Handle);
  end;

  SList := TStringList.Create;
  SList.LoadFromFile(ConfigFileName);
  Index := FindKey(SList, Key);
  if Index <> -1 then SList[Index] := Format('%s%s%s', [Key, #9, Value])
  else SList.Add(Format('%s%s%s', [Key, #9, Value]));
  SList.SaveToFile(ConfigFileName);
  SList.Free;
  SetKey := true;
end;
//------------------------------------------------------------------------------

function MGetKey(ConfigFileName, Key: string): string;
var
  Index, Pos: integer;
begin
  MGetKey := '%' + Key;
  if not (FileExists(ConfigFileName)) then
  begin
    SetKey(ConfigFileName, Key, '');
    Exit;
  end;

  if MList = nil then
  begin
    MList := TStringList.Create;
    MList.LoadFromFile(ConfigFileName);
  end;
  Index := FindKey(MList, Key);
  if Index <> -1 then
  begin
    Pos := FindValuePos(MList[Index]);
    if Pos <> -1 then MGetKey := KillSpace(Copy(MList[Index], Pos + 1, length(MList[Index])));
  end
  else
    SetKey(ConfigFileName, Key, '');

end;

function LGetKey(ConfigFileName, Key: string): string;
var
  Index, Pos: integer;
begin
  LGetKey := '%' + Key;
  if not (FileExists(ConfigFileName)) then
  begin
    SetKey(ConfigFileName, Key, '');
    Exit;
  end;

  if LList = nil then
  begin
    LList := TStringList.Create;
    LList.LoadFromFile(ConfigFileName);
  end;
  Index := FindKey(LList, Key);
  if Index <> -1 then
  begin
    Pos := FindValuePos(LList[Index]);
    if Pos <> -1 then LGetKey := KillSpace(Copy(LList[Index], Pos + 1, length(LList[Index])));
  end
  else
    SetKey(ConfigFileName, Key, '');

end;

//------------------------------------------------------------------------------



function GetKeyValue(Value: string; Number: integer): string;
var
  Count: integer;
begin
  GetKeyValue := '%' + IntToStr(Number);
  if Value = '' then Exit;
  Count := 0;
  repeat
    inc(Count);
    if Count < number then Value := Copy(Value, GetPos(Value) + 1, length(Value));
  until Count >= Number;

  Value := Value + ' ';
  Value := Copy(Value, 1, GetPos(Value) - 1);

  if Value <> '' then GetKeyValue := Value;
end;
//------------------------------------------------------------------------------
// Configs
//------------------------------------------------------------------------------

function GetMKey(Key: string): string;
begin
  GetMKey := MGetKey(ConfigsFolder + GeneralCfg, Key);
end;
//------------------------------------------------------------------------------

function GetMNextKey(Key: string): string;
begin
  GetMNextKey := MGetKey(ConfigsFolder + GeneralCfg, Key);
end;
//------------------------------------------------------------------------------

function SetMKey(Key, Value: string): boolean;
begin
  SetMKey := SetKey(ConfigsFolder + GeneralCfg, Key, Value);
end;
//------------------------------------------------------------------------------

function GetLKey(Key: string): string;
var
  s: string;
begin
  s := LGetKey(Format('%s\%s\%s', [ConfigsFolder, LanguagesFolders[CurrentLanguage], LanguageCfg]), Key);
  GetLKey := s;
end;

function GetLKey(Key, Caption: string): string;
var
  s: string;
begin
  s := LGetKey(Format('%s\%s\%s', [ConfigsFolder, LanguagesFolders[CurrentLanguage], LanguageCfg]), Key);
  if s[1] = '%' then SetKey(Format('%s\%s\%s', [ConfigsFolder, LanguagesFolders[CurrentLanguage], LanguageCfg]), Key, Caption);
  GetLKey := s;
end;


function GetLNextKey(Key: string): string;
begin
  GetLNextKey := LGetKey(Format('%s\%s\%s', [ConfigsFolder, LanguagesFolders[CurrentLanguage], LanguageCfg]), Key);
end;


function GetWordStringPos(const Index: Integer; const s: string; const Delimetr: TSysCharSet): Integer;
var
  Count, I: Integer;
begin
  count := 0;
  i := 1;
  result := 0;
  while (i <= Length(S)) and (Count <> Index) do begin
    while (i <= Length(s)) and (s[i] in Delimetr) do i := i + 1;
    if i <= Length(s) then Count := Count + 1;
    if Count <> Index then
      while (i <= Length(s)) and not (s[i] in Delimetr) do i := i + 1
    else Result := i;
  end;
end;

function GetWordString(Index: integer; const s: string; const Delimetr: TSysCharSet): string;
var
  i, len: integer;
begin
  len := 0;
  i := GetWordStringPos(Index, s, Delimetr);
  if i <> 0 then
    while (i <= Length(s)) and not (s[i] in Delimetr) do
    begin
      len := len + 1;
      SetLength(Result, Len);
      Result[Len] := S[I];
      i := i + 1;
    end;
  SetLength(Result, Len);
end;
//------------------------------------------------------------------------------

procedure GetPrivilegeNames(Strings: TStrings);
const
  TokenSize = 800;
var
  hToken: THandle;
  pTokenInfo: PTOKENPRIVILEGES;
  ReturnLen: Cardinal;
  i: Integer;
  PrivName: PChar;
  NameSize: Cardinal;
  DisplSize: Cardinal;
  LangId: Cardinal;
begin
  GetMem(pTokenInfo, TokenSize);
  try
    lastError := 0;
    if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
    begin
      lastError := GetLastError;
      AddToLog('Can''t get token: ' + IntToStr(lastError));
    end;

    if not GetTokenInformation(hToken, TokenPrivileges, pTokenInfo, TokenSize, ReturnLen) then
    begin
      lastError := GetLastError;
      AddToLog('Can''t get token(2): ' + IntToStr(lastError));
    end
    else
    begin
      GetMem(PrivName, 255);
      try
        for i := 0 to pTokenInfo.PrivilegeCount - 1 do
        begin
          NameSize := 255;
          LookupPrivilegeName(nil, pTokenInfo.Privileges[i].Luid, PrivName, Namesize);
          Strings.Add(PrivName);
        end;
      finally
        FreeMem(PrivName);
      end;
    end;
  finally
    FreeMem(pTokenInfo);
  end;
end;

function SetPrivileges: boolean;
const
  SeBackupPrivilege = 'SeBackupPrivilege';
  SeRestorePrivilege = 'SeRestorePrivilege';
  SeShutdownPrivilege = 'SeShutdownPrivilege';
var
  PrivilegeList: TStringList;
  IndexInList: integer;
begin
  Result := true;
  PrivilegeList := TStringList.Create;
  try
    PrivilegeList.Sorted := true;
    PrivilegeList.CaseSensitive := false;
    GetPrivilegeNames(PrivilegeList);
    AddToLog('Privileges list: ' + PrivilegeList.CommaText);
    if PrivilegeList.Count > 0 then begin
      IndexInList := 0;
      if not PrivilegeList.Find(SeBackupPrivilege, IndexInList) then
      begin
        AddToLog('Privilege found: ' + SeBackupPrivilege);
        Result := false;
      end
      else
      begin
        if not EnablePrivileges(SeBackupPrivilege) then begin
          AddToLog('Privilege not enable: ' + SeBackupPrivilege);
          Result := false;
        end
        else
          AddToLog('Privilege enabled: ' + SeBackupPrivilege);
      end;

      IndexInList := 0;
      if not PrivilegeList.Find(SeRestorePrivilege, IndexInList) then
      begin
        AddToLog('Privilege found: ' + SeRestorePrivilege);
        Result := false;
      end
      else
      begin
        if not EnablePrivileges(SeRestorePrivilege) then
        begin
          AddToLog('Privilege not enable: ' + SeRestorePrivilege);
          Result := false;
        end
        else AddToLog('Privilege enabled: ' + SeRestorePrivilege);
      end;

      IndexInList := 0;
      if not PrivilegeList.Find(SeShutdownPrivilege, IndexInList) then
      begin
        AddToLog('Privilege found: ' + SeShutdownPrivilege);
        Result := false;
      end
      else
      begin
        if not EnablePrivileges(SeShutdownPrivilege) then
        begin
          AddToLog('Privilege not enable: ' + SeShutdownPrivilege);
          Result := false;
        end
        else
          AddToLog('SeBackupPrivilege: ' + SeShutdownPrivilege);
      end;
    end
    else
      Result := false;
  finally
    PrivilegeList.Destroy;
  end;
end;


function EnablePrivileges(const NamePrivilege: string): Boolean;
{Определение привилегий для сохранений SeBackupPrivilege}
var
  hToken, CurrentProcess: THandle;
  tp: TTokenPrivileges;
  BackupNameValue: Int64;
  ret: Cardinal;
begin
  Result := False;
  CurrentProcess := GetCurrentProcess;
//     lastError := GetLastError;
//     if lastError <> 0 then begin
//       ShowMessageFmt(  'Получение идентификатора процесса %x %s.', [lastError, StringToWideChar(
//                SysErrorMessage(lastError),  errorBuf, SizeOf(errorBuf))]);
//       exit;
//     end;

  if not OpenProcessToken(CurrentProcess,
    TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then begin
    lastError := GetLastError;
  end;

  if not LookupPrivilegeValue(nil, PChar(NamePrivilege), BackupNameValue) then begin
    lastError := GetLastError;
  end;

//  tp.PrivilegeCount := SE_PRIVILEGE_ENABLED_BY_DEFAULT;
  tp.PrivilegeCount := SE_PRIVILEGE_ENABLED;
  tp.Privileges[0].Luid := BackupNameValue;
  tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
  if AdjustTokenPrivileges(hToken, False, tp,
    sizeof(tp), nil, ret) then
    Result := True else begin
    lastError := GetLastError;
  end;
  CloseHandle(hToken);
end;

function StringToDotString(SourceStr: string): string;
const
  DotStep = 3;
  SepareteChar = ',';
var
  TmpStr: string;
  Count, DotCount: integer;
begin
  if SourceStr = '' then Exit;
  result := '';
  TmpStr := '';
  DotCount := 0;
  for Count := length(SourceStr) downto 1 do
  begin
    if DotCount = DotStep then
    begin
      TmpStr := TmpStr + SepareteChar;
      DotCount := 0;
    end;
    TmpStr := TmpStr + SourceStr[Count];
    inc(DotCount);
  end;
  for Count := length(TmpStr) downto 1 do result := result + TmpStr[Count];
end;

//http://www.delphikingdom.ru/asp/answer.asp?IDAnswer=75962

function Is64bitOS: Boolean;
type
 TIsWow64Process = function(Handle: Windows.THandle; var Res: Windows.BOOL): Windows.BOOL; stdcall;var
  IsWow64Result: Windows.BOOL; // Result from IsWow64Process
  IsWow64Process: TIsWow64Process; // IsWow64Process fn reference
begin
  // Try to load required function from kernel32
  IsWow64Process := Windows.GetProcAddress(Windows.GetModuleHandle('kernel32.dll'), 'IsWow64Process');
  if Assigned(IsWow64Process) then
  begin
    if not IsWow64Process(Windows.GetCurrentProcess, IsWow64Result) then Result := False;
    // Return result of function
    Result := IsWow64Result;
  end
  else
    // Function not implemented: can't be running on Wow64
    Result := False;
end;




end.

