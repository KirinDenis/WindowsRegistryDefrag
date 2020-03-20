unit SettingsFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, jpeg, ShellAPI, Settings;

type
  TSettingsForm = class(TForm)
    SpeedButton1: TSpeedButton;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ComboBox1: TComboBox;
    Label6: TLabel;
    ComboBox2: TComboBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure SpeedButton1Click(Sender: TObject);
    procedure Label2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image4MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Label9Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  SettingsForm: TSettingsForm;

implementation

uses Main;

{$R *.dfm}

procedure TSettingsForm.SpeedButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TSettingsForm.Label2MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   TLabel(Sender).Font.Style := TLabel(Sender).Font.Style + [fsUnderline];
end;

procedure TSettingsForm.Image4MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Label9.Font.Style := Label9.Font.Style - [fsUnderline];
  Label2.Font.Style := Label2.Font.Style - [fsUnderline];

end;

procedure TSettingsForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then Close;
 if Key = VK_RETURN then Label9Click(Sender);
end;

procedure TSettingsForm.Label9Click(Sender: TObject);
begin
  if ComboBox1.ItemIndex = 0  then SetMKey('CreatBackup', 'True')
   else SetMKey('CreatBackup', 'False');

  if ComboBox2.ItemIndex = 0  then SetMKey('CheckForUpdate', 'True')
   else SetMKey('CheckForUpdate', 'False');

  Close; 
end;

procedure TSettingsForm.FormActivate(Sender: TObject);
begin
  MainForm.AdjustLabels(Image2, Label1, Label2, nil, nil, nil);
end;

procedure TSettingsForm.Label2Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar(ProductHomePage), nil, nil, SW_NORMAL);
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
begin
  if StrToBoolDef(GetMKey('CreatBackup'), True) then ComboBox1.ItemIndex := 0
   else ComboBox1.ItemIndex := 1;

  if StrToBoolDef(GetMKey('CheckForUpdate'), True) then ComboBox2.ItemIndex := 0
   else ComboBox2.ItemIndex := 1;

end;

end.
