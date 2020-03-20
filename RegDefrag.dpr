program RegDefrag;

uses
  Forms,
  Windows,
  SysUtils,
  Main in 'Main.pas' {MainForm},
  Settings in 'Settings.pas',
  VMan in 'VMan.pas',
  RegFilesCollection in 'RegFilesCollection.pas',
  RegFileList in 'RegFileList.pas' {RegListForm},
  Defrag in 'Defrag.pas',
  TestRegistry in 'TestRegistry.pas' {TestRegistryForm},
  About in 'About.pas' {AboutForm},
  Registration in 'Registration.pas' {RegistrationForm},
  Register in 'Register.pas',
  SettingsFormUnit in 'SettingsFormUnit.pas' {SettingsForm};

{$R *.res}
{$R VMan.res}
begin
  SetDebugErrorLevel(0);
  SetErrorMode($FFFF);

  WorkFolder := ExtractFileDir(paramstr(0)) + '\';
  ConfigsFolder := WorkFolder + ConfigsFolder;
  ChDir(WorkFolder);
  DebugMode := StrToBoolDef(GetMKey('DebugMode'), False);
  try


    SetPrivileges;
    GetHiveList;
{  if not SetPrivileges then begin
    AddToLog(SMessagePrivilegesShow, []);
    StartDefragEnabled := false;
  end;}


    CurrentLanguage := StrToInt(GetMKey('SelectedLanguage'));
    LanguagesCount := 0;
    LanguagesFolders[LanguagesCount] := GetKeyValue(GetMKey('Language'), 1);

    Application.Initialize;
    Application.Title := 'Registry Defrag 2010';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TRegListForm, RegListForm);
  Application.CreateForm(TTestRegistryForm, TestRegistryForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TRegistrationForm, RegistrationForm);
  Application.CreateForm(TSettingsForm, SettingsForm);
  MainForm.SetLanguage;
  except
    on E: Exception do
    begin
      Application.MessageBox(PChar('Loading resource fault: ' + E.Message + #$0D + #$0A + 'Reinstall Reg Defrag'), 'Reg Defrag', 0);
      ExitProcess(1);
    end;
  end;

  Application.Run;
end.

