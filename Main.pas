unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, VMan, ComCtrls, ExtCtrls, Settings, ActnList, Menus,
  jpeg, RegFilesCollection, Defrag, Buttons, OleCtrls, SHDocVw, Register,
  ShellAPI, AppEvnts;

const
  MainVersionNumber = 1;
  ShowNoUpdateFlag: boolean = True;
type
  TMainForm = class(TForm)
    ActionList1: TActionList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Label5: TLabel;
    Label6: TLabel;
    Image8: TImage;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Image2: TImage;
    Image13: TImage;
    Label18: TLabel;
    Label19: TLabel;
    SpeedButton1: TSpeedButton;
    Browser: TWebBrowser;
    Label20: TLabel;
    ApplicationEvents1: TApplicationEvents;
    Image15: TImage;
    Image16: TImage;
    Image17: TImage;
    Image18: TImage;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Image23: TImage;
    Label7: TLabel;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Image1: TImage;
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Label2MouseEnter(Sender: TObject);
    procedure Label8Click(Sender: TObject);
    procedure Label14Click(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure BrowserBeforeNavigate2(Sender: TObject;
      const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    procedure BrowserDocumentComplete(Sender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure Label17Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label19Click(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure SetComponentLanguage(FormName: string; Component: TComponent);
    procedure SetFormLanguage(Form: TForm);
  public
    procedure SetLanguage;
    procedure SetStatistics;
    procedure AdjustLabels(ALabel1, ALabel2, ALabel3, ALabel4, ALabel5, ALabel6: TControl);
  end;

var
  MainForm: TMainForm;

  LastAnalyse,
    AnalyseTime,
    UnfragSize,
    DefragSize,
    LastPercent: string;

implementation

uses RegFileList, TestRegistry, About, Registration, SettingsFormUnit;
{$R *.dfm}
const
  UpdateInformationLink = 'http://dci-software.com/defrag.txt';
  UpdateInformationLinkRedirect = 'http://dci-software.com/defrag.txt';
  FileName: string = '';

procedure TMainForm.SetComponentLanguage(FormName: string; Component: TComponent);
var
  i, SafeIndex: integer;
  ComboBox: TComboBox;
begin
  try
    if IsWindowsVista then
      if (Component.ClassName = 'TLabel')
        or
        (Component.ClassName = 'TTreeView')
        or
        (Component.ClassName = 'TListView')
        or
        (Component.ClassName = 'TButton')
        or
        (Component.ClassName = 'TToolBar')
        or
        (Component.ClassName = 'TCoolBar')
        or
        (Component.ClassName = 'TSpeedButton')
        or
        (Component.ClassName = 'TPageControl')
        or
        (Component.ClassName = 'TScrollBar')
        or
        (Component.ClassName = 'TEdit')
        or
        (Component.ClassName = 'TUpDown')
        or
        (Component.ClassName = 'TRadioButton')
        or
        (Component.ClassName = 'TStausBar')
        or
        (Component.ClassName = 'TDBGrid')
        or
        (Component.ClassName = 'TComboBox')
        or
        (Component.ClassName = 'TCheckBox') then
      begin
        SetVistaFonts(TForm(Component));
        if (Component.ClassName <> 'TLabel') then
          SetVistaTreeView(TTreeView(Component).Handle);
      end
      else
        Self.DoubleBuffered := true;
  except
  end;

  if Component.ClassName = 'TPanel' then
    TPanel(Component).ControlStyle := TPanel(Component).ControlStyle - [csParentBackground];

  if Component.ClassName = 'TLabel' then
    TLabel(Component).Caption :=
      GetLKey(FormName + '.' +
      TLabel(Component).Name + '.caption',
      TLabel(Component).Caption);

  if Component.ClassName = 'TComboBox' then
  begin
    ComboBox := TComboBox(Component);
    SafeIndex := ComboBox.ItemIndex;
    for i := 0 to ComboBox.Items.Count - 1 do
      ComboBox.Items[i] := GetLKey(FormName + '.' +
        ComboBox.Name + '.Item' + IntToStr(i) + '', ComboBox.Items[i]);
    ComboBox.ItemIndex := SafeIndex;
  end;

  if Component.ClassName = 'TCheckBox' then
  begin
    TCheckBox(Component).Caption :=
      GetLKey(FormName + '.' +
      TCheckBox(Component).Name + '.caption',
      TCheckBox(Component).Caption);
  end;

  if Component.ClassName = 'TRadioButton' then
  begin
    TRadioButton(Component).Caption :=
      GetLKey(FormName + '.' +
      TRadioButton(Component).Name + '.caption',
      TRadioButton(Component).Caption);
  end;

  if Component.ClassName = 'TButton' then
  begin
    TButton(Component).Caption :=
      GetLKey(FormName + '.' +
      TButton(Component).Name + '.caption',
      TButton(Component).Caption);
  end;

  if Component.ClassName = 'TAction' then
  begin
    TAction(Component).Caption :=
      GetLKey(FormName + '.' +
      TAction(Component).Name + '.caption',
      TAction(Component).Caption);

    TAction(Component).Hint :=
      GetLKey(FormName + '.' +
      TAction(Component).Name + '.hint',
      TAction(Component).hint);

    TAction(Component).ShortCut :=
      TextToShortCut(GetMKey(FormName + '.' +
      TAction(Component).Name + '.ShortCut'));
  end;

end;

procedure TMainForm.SetFormLanguage(Form: TForm);
var
  ComponentCount: integer;
begin
  if Form.Name = '' then Exit;
    //Vista
  SetVistaFonts(Form);
  SetVistaTreeView(Form.Handle);

  Form.Caption := GetLKey(Form.ClassName + '.caption', Form.Caption);
  for ComponentCount := 0 to Form.ComponentCount - 1 do
    SetComponentLanguage(Form.ClassName, Form.Components[ComponentCount]);
end;


procedure TMainForm.SetLanguage;
var
  FormCount: integer;
  CanUnlock: boolean;
begin
  //Set national languges and shortcuts for all windows and actions
  for FormCount := 0 to Application.ComponentCount - 1 do
    SetFormLanguage(TForm(Application.Components[FormCount]));

  AdjustLabels(Image3, Label2, Image4, Label3, Image5, Label4);

  Label6.Caption := Format(GetLKey('TMainForm.Label6.caption'), [StringToDotString(IntToStr(HivePath.Count)), StringToDotString(IntToStr(AllSize))]);


  MainForm.Caption := GetLKey('TMainForm.Caption') + ' ' + GetLKey('Unregister');

  CanUnlock := False;
  if GetRegisterStatus = -1 then
  begin
    CanUnlock := True;
    MainForm.Caption := GetLKey('TMainForm.Caption') + ' ' + GetLKey('Registred');
  end
  else
    if GetMKey('LastDefrag')[1] = '%' then CanUnlock := True;

  if CanUnlock then
  begin
    Label20.Visible := false;

    Label10.enabled := true;
    Label13.enabled := true;
  //  Label14.enabled := true;
  end;

  SetStatistics;
end;

procedure TMainForm.SetStatistics;
begin

  LastAnalyse := GetMKey('LastAnalyse');
  AnalyseTime := GetMKey('AnalyseTime');
  UnfragSize := GetMKey('UnfragSize');
  DefragSize := GetMKey('DefragSize');
  LastPercent := GetMKey('LastPercent');

  if LastAnalyse[1] = '%' then
  begin
    Label21.Caption := GetLKey('NeverLastAnalyseDate');
    Label22.Caption := GetLKey('NeverAnalyseTime');
    Label23.Caption := Format(GetLKey('TMainForm.Label23.caption'), [StringToDotString(IntToStr(AllSize))]);
    Label24.Caption := GetLKey('NeverDefragSize');
    Label25.Caption := GetLKey('NeverDLastPercent');
    Label26.Caption := GetLKey('NeverWeRecomendAnalyse');
    Label26.Visible := True;
  end
  else
  begin
    Label21.Caption := Format(GetLKey('TMainForm.Label21.caption'), [LastAnalyse]);
    Label22.Caption := Format(GetLKey('TMainForm.Label22.caption'), [AnalyseTime]);
    Label23.Caption := Format(GetLKey('TMainForm.Label23.caption'), [StringToDotString(UnfragSize)]);
    Label24.Caption := Format(GetLKey('TMainForm.Label24.caption'), [StringToDotString(DefragSize)]);
    Label25.Caption := Format(GetLKey('TMainForm.Label25.caption'), [LastPercent, '%']);
    if StrToIntDef(LastAnalyse, 0) > 50 then
    begin
      Label26.Caption := GetLKey('NeverWeRecomendAnalyse');
      Label26.Visible := True;
    end
    else
      Label26.Visible := False;

  end;

  AdjustLabels(Label25, Label26, nil, nil, nil, nil);
//  AdjustLabels(Label21, Image21, Label22, nil, nil, nil);

  if GetMKey('LastDefrag')[1] = '%' then
  begin
    Label7.Caption := GetLKey('YouNeverDefrag');
  end
  else
  begin
    Label7.Caption := Format(GetLKey('LastDefrag'), [GetMKey('LastDefrag')]);
    Label7.Font.Color := $00313131;
  end;


end;

procedure TMainForm.AdjustLabels(ALabel1, ALabel2, ALabel3, ALabel4, ALabel5, ALabel6: TControl);
begin
  if (ALabel1 = nil) or (ALabel2 = nil) then Exit;
  ALabel2.Left := ALabel1.Left + ALabel1.Width + 7;

  if (ALabel3 = nil) then Exit;
  ALabel3.Left := ALabel2.Left + ALabel2.Width + 7;

  if (ALabel4 = nil) then Exit;
  ALabel4.Left := ALabel3.Left + ALabel3.Width + 7;

  if (ALabel5 = nil) then Exit;
  ALabel5.Left := ALabel4.Left + ALabel4.Width + 7;

  if (ALabel6 = nil) then Exit;
  ALabel6.Left := ALabel5.Left + ALabel5.Width + 7;
end;

procedure TMainForm.Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  Label2.Font.Style := Label2.Font.Style - [fsUnderline];
  Label3.Font.Style := Label3.Font.Style - [fsUnderline];
  Label4.Font.Style := Label4.Font.Style - [fsUnderline];

//  Label12.Font.Style := Label12.Font.Style - [fsUnderline];
//  Label14.Font.Style := Label14.Font.Style - [fsUnderline];
//  Label17.Font.Style := Label17.Font.Style - [fsUnderline];

  Label5.Font.Style := Label5.Font.Style - [fsUnderline];
  Label9.Font.Style := Label9.Font.Style - [fsUnderline];
  Label10.Font.Style := Label10.Font.Style - [fsUnderline];
  Label15.Font.Style := Label15.Font.Style - [fsUnderline];

  Label19.Font.Style := Label15.Font.Style - [fsUnderline];
end;

procedure TMainForm.Label2MouseEnter(Sender: TObject);
begin
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style + [fsUnderline];
end;

procedure TMainForm.Label8Click(Sender: TObject);
begin
  RegListForm.ShowModal;
end;

procedure TMainForm.Label14Click(Sender: TObject);
begin
  TestRegistryForm.Mode := [DMDefrag];
  TestRegistryForm.Show;
  TestRegistryForm.StartDefrag;
end;

procedure TMainForm.Label12Click(Sender: TObject);
begin
  TestRegistryForm.Mode := [DmTest];
  TestRegistryForm.Show;
  TestRegistryForm.StartTest;
end;

procedure TMainForm.Label5Click(Sender: TObject);
begin
  RegListForm.ShowModal;
end;

procedure TMainForm.Label4Click(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMainForm.FormActivate(Sender: TObject);
var
  Flags: OleVariant;
begin
//  MainForm.AdjustLabels(Image14, Label18, Label19, nil, nil, nil);

  if StrToBoolDef(GetMKey('CheckForUpdate'), True) then
  begin
    ShowNoUpdateFlag := False;
    FileName := '';
    Flags := navNoHistory or navNoReadFromCache or navNoWriteToCache;
    Browser.Navigate(UpdateInformationLink, Flags);
  end;

end;

procedure TMainForm.SpeedButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.Label3Click(Sender: TObject);
begin
  RegistrationForm.ShowModal;
end;

procedure TMainForm.BrowserBeforeNavigate2(Sender: TObject; const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
begin
  URL := Browser.LocationURL;
  if (URL <> '')
    and
    (URL <> UpdateInformationLink)
    and
    (URL <> UpdateInformationLinkRedirect)
    and
    (URL <> 'about.blank') then
  begin
    Cancel := true;
  end;
end;

procedure TMainForm.BrowserDocumentComplete(Sender: TObject; const pDisp: IDispatch; var URL: OleVariant);
var
  Document: OleVariant;
  Text: string;
  Version: integer;
  Flags: OleVariant;
begin
  try
    URL := Browser.LocationURL;
    if (URL = UpdateInformationLink)
      or
      (URL = UpdateInformationLinkRedirect) then
    begin
      if FileName <> '' then Exit;
      Document := Browser.Document;
      Text := Document.Body.innerText;
      Version := StrToIntDef(Copy(Text, 1, pos(#$0D, Text) - 1), 0);
      FileName := Copy(Text, pos(#$0D, Text) + 2, length(Text));
      if Version > MainVersionNumber then
      begin
        if Application.MessageBox(PChar(GetLKey('RedyToUpdate')), 'Registry Defrag ready for Update', MB_YESNO) = IDYES then
        begin
          Flags := navNoHistory or navNoReadFromCache or navNoWriteToCache;
          browser.Navigate(FileName, Flags);
        end;
      end
      else
        if ShowNoUpdateFlag then
        begin
          ShowMessage(GetLKey('NoUpdateForThisVersion'));
          ShowNoUpdateFlag := false;
        end;
    end;
  except
  //Update problem
  end;
end;


procedure TMainForm.Label17Click(Sender: TObject);
var
  Flags: OleVariant;
begin
  ShowNoUpdateFlag := True;
  FileName := '';
  Flags := navNoHistory or navNoReadFromCache or navNoWriteToCache;
  Browser.Navigate(UpdateInformationLink, Flags);
end;

procedure TMainForm.Label2Click(Sender: TObject);
begin
  SettingsForm.ShowModal;
end;

procedure TMainForm.Label19Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar(ProductHomePage), nil, nil, SW_NORMAL);
end;

procedure TMainForm.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  AddToLog(E.Message);
  if Settings.DebugMode then ShowMessage(E.Message);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
end;

end.

