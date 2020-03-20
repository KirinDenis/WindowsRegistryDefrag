unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, jpeg, ExtCtrls, ShellAPI, Settings;

type
  TAboutForm = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    Label2: TLabel;
    Label3: TLabel;
    Image3: TImage;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Image4: TImage;
    procedure FormActivate(Sender: TObject);
    procedure Label3MouseEnter(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Label3Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure Label8Click(Sender: TObject);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
  public
  end;

var
  AboutForm: TAboutForm;

implementation
uses Main;
{$R *.dfm}

procedure TAboutForm.FormActivate(Sender: TObject);
begin
  MainForm.AdjustLabels(Image3, Label2, Label3, nil, nil, nil);
end;

procedure TAboutForm.Label3MouseEnter(Sender: TObject);
begin
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style + [fsUnderline];
end;

procedure TAboutForm.SpeedButton1Click(Sender: TObject);
begin
 Close;
end;

procedure TAboutForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then Close;
 if Key = VK_RETURN then Close;

end;

procedure TAboutForm.Label3Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar(ProductHomePage), nil, nil, SW_NORMAL);
end;

procedure TAboutForm.Label7Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar(ProductBuyPage), nil, nil, SW_NORMAL);
end;

procedure TAboutForm.Label8Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar(ProductSupportPage), nil, nil, SW_NORMAL);
end;

procedure TAboutForm.Image2MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Label3.Font.Style := Label3.Font.Style - [fsUnderline];
  Label7.Font.Style := Label7.Font.Style - [fsUnderline];
  Label8.Font.Style := Label8.Font.Style - [fsUnderline];
end;

end.
