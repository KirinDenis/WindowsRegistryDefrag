unit RegFileList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, jpeg, StdCtrls,  RegFilesCollection, ImgList, Settings,
  Buttons;

type
  TRegListForm = class(TForm)
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel5: TPanel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Label1: TLabel;
    Panel3: TPanel;
    ListView1: TListView;
    Panel4: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Image9: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Image10: TImage;
    ImageList1: TImageList;
    Panel9: TPanel;
    SpeedButton1: TSpeedButton;
    procedure ListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure ListView1CustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label5MouseEnter(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpeedButton1Click(Sender: TObject);
  private

  public

  end;

var
  RegListForm: TRegListForm;

implementation

{$R *.dfm}

procedure TRegListForm.ListView1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Item.Index and 1 > 0 then
    TListView(Sender).Canvas.Brush.Color := $00F4F4F4;

  if Item.Indent = 0 then  TListView(Sender).Canvas.Font.Style := [fsBold]
   else TListView(Sender).Canvas.Font.Color := clGray;
end;

procedure TRegListForm.ListView1CustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  if Item.Index and 1 > 0 then
    TListView(Sender).Canvas.Brush.Color := $00F4F4F4;
end;

procedure TRegListForm.FormShow(Sender: TObject);
var
 ListItem: TListItem;
 i: integer;

begin
  ListView1.Clear;
 for i:= 0 to HivePath.Count-1 do
  begin
    ListItem := ListView1.Items.Add;
    ListItem.Caption := RegKeysList[i];
    ListItem.SubItems.Add(StringToDotString(IntToStr(Integer(HivePath.Objects[i]))));
    ListItem.ImageIndex := 1;

    ListItem := ListView1.Items.Add;
    ListItem.Caption := HivePath[i];
    ListItem.Indent := 1;
    ListItem.ImageIndex := -1;
  end;

  Label3.Caption := Format(GetLKey('TMainForm.Label6.caption'), [StringToDotString(IntToStr(HivePath.Count)), StringToDotString(IntToStr(AllSize))]);

  Panel7.Width := Panel7.Width + 1; 
end;

procedure TRegListForm.Label5Click(Sender: TObject);
begin
 Close;
end;

procedure TRegListForm.Label5MouseEnter(Sender: TObject);
begin
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style + [fsUnderline];
end;

procedure TRegListForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then Close;
end;

procedure TRegListForm.SpeedButton1Click(Sender: TObject);
begin
 Close;
end;

end.
