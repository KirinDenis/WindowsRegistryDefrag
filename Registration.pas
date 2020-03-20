unit Registration;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Settings, Buttons, StdCtrls, jpeg, ExtCtrls, Register, ShellAPI;

type
  TRegistrationForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Edit1: TEdit;
    Label5: TLabel;
    SpeedButton1: TSpeedButton;
    Image4: TImage;
    Label6: TLabel;
    Label7: TLabel;
    procedure Label7MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Label7Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
  private
  public
  end;

var
  RegistrationForm: TRegistrationForm;

implementation

uses Main;

{$R *.dfm}

procedure TRegistrationForm.Label7MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style + [fsUnderline];
end;

procedure TRegistrationForm.Image1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Label5.Font.Style := Label5.Font.Style - [fsUnderline];
  Label7.Font.Style := Label7.Font.Style - [fsUnderline];
end;

procedure TRegistrationForm.SpeedButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TRegistrationForm.Edit1Change(Sender: TObject);
var
  s: string;
begin
  s := Edit1.Text;
  s := DeHash(s);
  if Pos('RD2010', s) > 0 then
  begin
    ShowMessage(GetLKey('ThankForRegistration'));
    SetMKey('RegKey', Edit1.Text);
    MainForm.Caption := GetLKey('MainForm.Caption') + ' ' + GetLKey('Registred');
    MainForm.Label20.Visible := false;
    MainForm.Label10.enabled := true;
    MainForm.Label13.enabled := true;
   // MainForm.Label14.enabled := true;
    Close;
  end;
end;

procedure TRegistrationForm.FormActivate(Sender: TObject);
begin
  MainForm.AdjustLabels(Image4, Label6, Label7, nil, nil, nil);
end;

procedure TRegistrationForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if Key = VK_RETURN then Close;
end;

procedure TRegistrationForm.Label7Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar(ProductHomePage), nil, nil, SW_NORMAL);
end;

procedure TRegistrationForm.Label5Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar(ProductBuyPage), nil, nil, SW_NORMAL);
end;

end.

