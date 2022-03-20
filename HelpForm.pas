unit HelpForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmHelp = class(TForm)
    Help: TMemo;
    btnOK: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmHelp: TfrmHelp;

implementation

{$R *.dfm}

procedure TfrmHelp.btnOKClick(Sender: TObject);
begin
  frmHelp.Hide;
end;

procedure TfrmHelp.FormShow(Sender: TObject);
begin
  Help.Lines.LoadFromFile('Help.txt');
end;

end.
