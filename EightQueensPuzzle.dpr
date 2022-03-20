program EightQueensPuzzle;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {frmMain},
  HelpForm in 'HelpForm.pas' {frmHelp};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmHelp, frmHelp);
  Application.Run;
end.
