unit Unit1;

interface

uses
  VclStylePreview, VclStyleUtil,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Themes,
  Vcl.Buttons, Vcl.Imaging.pngimage;

type
  TfrmMain = class(TForm)
    Stylekonfig: TGroupBox;
    Label8: TLabel;
    lbSelStyle: TLabel;
    ListBox_Styles: TListBox;
    pnlstylepreview: TPanel;
    btnStyleAnwenden: TButton;
    Label1: TLabel;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    Label2: TLabel;
    lblBgColor: TLabel;
    lblTextColor: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnStyleAnwendenClick(Sender: TObject);
    procedure ListBox_StylesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
    FPreview : TVclStylesPreview;
    procedure LoadStyles;
    procedure SetStyle(SetStyleName:string);
  public
    { Public-Deklarationen }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

// --- Konfig --------------------------------------------------

const WindowsStyleName:string='Windows';
      csSeparator='-----------';

procedure TfrmMain.Loadstyles;
var i:Integer;
    sl:TStringList;
begin
  lbSelStyle.Caption:= TStyleManager.ActiveStyle.Name;
  Listbox_styles.Sorted:= false;
  ListBox_Styles.Items.Clear;

  sl:= nil;
  try
    sl:= ListStyles;
    for i:= 0 to pred(sl.Count) do
      Listbox_Styles.Items.Add(sl.Strings[i]);
  finally
    FreeAndNil(sl);
  end;
end;

procedure TfrmMain.btnStyleAnwendenClick(Sender: TObject);
begin
  SetStyle(lbSelStyle.Caption);
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if assigned(FPreview) then
    FreeAndNil(FPreview);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  LoadStyles;
end;

procedure TfrmMain.ListBox_StylesClick(Sender: TObject);
var
   LStyle : TCustomStyleServices;
begin
 // Vorschau
 if listbox_styles.itemindex < 0 then exit;
 if listbox_styles.Items.Strings[listbox_styles.ItemIndex]=csseparator then exit;

 lbSelStyle.Caption:= listbox_styles.Items.Strings[listbox_styles.ItemIndex];

 // Style vorschau
 LStyle:=TStyleManager.Style[listbox_styles.Items.Strings[listbox_styles.ItemIndex]];
 FreeAndNil(FPreview);
 FPreview:=TVclStylesPreview.Create(Self);
 FPreview.Parent:=pnlstylepreview;
 FPreview.BoundsRect := pnlstylepreview.ClientRect;

 FPreview.Caption:=listbox_styles.Items.Strings[listbox_styles.ItemIndex];
 // FPreview.Icon:=
 FPreview.Style:=LStyle;
end;

// --- Anwendung --------------------------------------------------

procedure TfrmMain.SetStyle(SetStyleName:string);
begin
 if (SetStyleName <> TStyleManager.ActiveStyle.Name) then
 begin
   try
     TStyleManager.SetStyle(SetStyleName);

     // Anpassung der Grafiken
     StyleChangeGlyphs(Self);

     lblBgColor.Caption:= 'GetStyleBgColor(): '+inttohex(GetStyleBgColor);
     lblTextColor.Caption:= 'GetStyleTextGlypColor(): '+inttohex(GetStyleTextGlypColor);
   except
     on e:Exception do
     begin
       //
     end;
   end;
 end;
end;


end.
