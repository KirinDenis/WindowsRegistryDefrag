unit Register;
interface
uses
  Windows, SysUtils, Settings, DateUtils, DECUtil, Cipher;

function GetRegisterStatus: integer;
//function GetInstallDateTime: TDateTime;
//function GetWindowsInstallTime: TDateTime;
function GetHash(var Source): string;
function DeHash(var Source): string;

const
  TrialPeriod = 10;
var
  RegisterStatus: integer;
implementation
uses Main;

function Code: string;
var
  Code: integer;
begin
  Code := 15;
  Result := chr(Code);
  inc(Code,23); Result := Result + chr(Code);
  dec(Code,32); Result := Result + chr(Code);
  inc(Code,11); Result := Result + chr(Code);
  dec(Code,12); Result := Result + chr(Code);
  inc(Code,33); Result := Result + chr(Code);
  dec(Code,87); Result := Result + chr(Code);
  inc(Code,65); Result := Result + chr(Code);
  dec(Code,32); Result := Result + chr(Code);
end;

function GetHash(var Source): string;
begin
  try
    with TCipher_Blowfish.Create(Code, nil) do
    try
      Mode := TCipherMode(0);
      Result := CodeString(string(Source), paEncode, fmtMIME64);
    finally
      Free;
    end;
  except
    Result := '';
  end;
end;

function DeHash(var Source): string;
begin
  result := '';
  try
    if String(Source) = '%PrivateKey' then Exit;
    with TCipher_Blowfish.Create(Code, nil) do
    try
      Mode := TCipherMode(0);
      Result := CodeString(string(Source), paDecode, fmtMIME64);
    finally
      Free;
    end;
  except
  end;
end;



function FileTimeToDateTime(AFileTime: TFileTime): TDateTime;

  function ValidFileTime(FileTime: TFileTime): Boolean;
  begin
    Result := (FileTime.dwLowDateTime <> 0) or (FileTime.dwHighDateTime <> 0);
  end;
var
  SysTime: TSystemTime;
  LocalFileTime: TFILETIME;
begin
  if ValidFileTime(AFileTime)
    and FileTimeToLocalFileTime(AFileTime, LocalFileTime)
    and FileTimeToSystemTime(LocalFileTime, SysTime) then
  try
    Result := SystemTimeToDateTime(SysTime)
  except
    Result := -1;
  end
  else
    Result := -1;
end;

function GetRegisterStatus: integer;
var
  s: string;
begin
  Result := $FF;
  s := GetMKey('RegKey');
  s := DeHash(s);
  if Pos('RD2010', s) > 0 then Result := -1;
end;



end.

