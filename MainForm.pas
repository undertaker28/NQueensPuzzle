unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids, System.Generics.Collections, JPEG, Vcl.Samples.Spin;

type
  TfrmMain = class(TForm)
    btnStart: TButton;
    btnStop: TButton;
    edtQueensCount: TSpinEdit;
    edtShowDelay: TSpinEdit;
    grdChessBoard: TDrawGrid;
    grpSolutionMethod: TRadioGroup;
    lblQueensCount: TLabel;
    lblShowDelay: TLabel;
    lblFoundSolutions: TLabel;
    lblSolutionCount: TLabel;
    pnlControls: TPanel;
    grpMethod: TRadioGroup;
    btnByHand: TButton;
    Image1, Image2, Image3, Image4, Image5, Image6, Image7, Image8: TImage;
    btnContinue: TButton;
    btnHelp: TButton;
    procedure btnStartClick(Sender: TObject);
    procedure grdChessBoardDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure edtQueensCountChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure grdChessBoardClick(Sender: TObject);
    procedure Check;
    procedure Correct;
    procedure grdChessBoardMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure grdChessBoardMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure btnByHandClick(Sender: TObject);
    procedure Drawing;
    procedure DeleteThisFileContent(const FileToClear: string);
    procedure MustHave(Col, Row: Integer; var Important1, Important2: Boolean);
    procedure edtShowDelayChange(Sender: TObject);
    procedure btnContinueClick(Sender: TObject);
    procedure grpSolutionMethodClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure RecursiveSolution;
    procedure StackSolution(RestoreLastSolution: Boolean);
    procedure edtQueensCountChangeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtShowDelayKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure grpMethodClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure DrawSolution(Solution: array of Integer); overload;
    procedure DrawSolution(Solution: TStack<Integer>); overload;
  end;

Const
  MaxQueensCount = 8;

Type
  TBoolAndString = record
    Interval: Integer;
    BoardDimension: Integer;
    Solve: String[8];
    Help: String[27];
  end;

var
  frmMain: TfrmMain;
  QueensCount: Integer;
  ShowDelay: cardinal;
  SolutionCount: Integer;
  StopPressed: Boolean;
  Queens: array [1 .. MaxQueensCount, 1 .. MaxQueensCount] of Boolean;
  img1, img2: TPicture;
  Temp: Integer;
  Mas: array [1 .. MaxQueensCount, 1 .. MaxQueensCount] of Integer;
  CountForCorrect: Integer;
  VisibleQueensCount: Integer;
  VisibleFlag: Boolean;
  Input: TextFile;
  ForCount: Integer;
  TypedFile: File of TBoolAndString;
  Need: TBoolAndString;

implementation

{$R *.dfm}

uses PNGImage, HelpForm;

procedure TfrmMain.DeleteThisFileContent(const FileToClear: string);
Begin
  Assignfile(Input,'Placements.txt');
  Rewrite(Input);
  Closefile(Input);
End;


//Recursive solution to the arrangement of all queens
procedure TfrmMain.RecursiveSolution;
var
  I: Integer;
  NoHorizontal: array [1 .. MaxQueensCount] of Boolean;
  NoDiagonal1: array [2 .. 2 * MaxQueensCount] of Boolean;
  NoDiagonal2: array [1 - MaxQueensCount .. MaxQueensCount - 1] of Boolean;
  Decision: array [1 .. MaxQueensCount] of Integer;
  {NoHorizontal - an array in which there is no queen on the j-th horizontal
   NoDiagonal1 - an array in which there is no queen on the k-th / diagonal (all fields on the diagonal / have a constant sum of coordinates i and j)
   NoDiagonal2 - an array in which there is no queen on the k-th \ diagonal (all fields on the diagonal \ have a constant difference of coordinates i and j)
   Decision - an array that contains the location of the queen on the i-th vertical
   I - cycle counter}

  procedure Solve(i: Integer);
  var
    j: Integer;
  begin
    if not StopPressed then
      for j := 1 to QueensCount do
      begin
        if NoHorizontal[j] and NoDiagonal1[i + j] and NoDiagonal2[i - j] then
        begin
          Decision[i] := j;
          NoHorizontal[j] := False;
          NoDiagonal1[i + j] := False;
          NoDiagonal2[i - j] := False;
          if i < QueensCount then
            Solve(i + 1)
          else
            frmMain.DrawSolution(Decision);
          NoHorizontal[j] := True;
          NoDiagonal1[i + j] := True;
          NoDiagonal2[i - j] := True;
        end;
      end
    else
    Begin
      Assignfile(TypedFile, 'MyTypedFile.dat');
      Rewrite(TypedFile);
      Need.BoardDimension := QueensCount;
      Need.Interval := ShowDelay;
      Closefile(TypedFile);
    End;
  end;

begin
  grdChessBoard.Enabled := False;
  for i := 1 to QueensCount do
    NoHorizontal[i] := True;
  for i := 2 to 2 * QueensCount do
    NoDiagonal1[i] := True;
  for i := 1 - QueensCount to QueensCount - 1 do
    NoDiagonal2[i] := True;
  Solve(1);
  btnStart.Enabled := True;
  btnByHand.Enabled := True;
end;


//Stack solution to the arrangement of all queens
procedure TfrmMain.StackSolution(RestoreLastSolution: Boolean);
var
  I, Y, x: Integer;
  NoHorizontal: array [1 .. MaxQueensCount] of Boolean;
  NoDiagonal1: array [2 .. 2 * MaxQueensCount] of Boolean;
  NoDiagonal2: array [1 - MaxQueensCount .. MaxQueensCount - 1] of Boolean;
  Stack: TStack<Integer>;
  {NoHorizontal - an array in which there is no queen on the j-th horizontal
   NoDiagonal1 - an array in which there is no queen on the k-th / diagonal (all fields on the diagonal / have a constant sum of coordinates i and j)
   NoDiagonal2 - an array in which there is no queen on the k-th \ diagonal (all fields on the diagonal \ have a constant difference of coordinates i and j)
   Decision - an array that contains the location of the queen on the i-th vertical
   I - cycle counter
   Y - value on the ordinate axis
   x - value on the abscissa axis
   Stack - delphic stack}

  Function Uspeh: Boolean;
  Var
    usp: Boolean;
  Begin
    usp := False;
    While (Y < QueensCount) And Not usp do
    Begin
      Y := Y + 1;
      usp := NoHorizontal[Y] and NoDiagonal1[x + Y] and NoDiagonal2[Y - x];
    End;
    Result := usp;
  End;

begin
  Stack := TStack<Integer>.Create;
    //First, in any case, fill in the array True - all the horizontals and diagonals are free
    For i := 1 to QueensCount do
      NoHorizontal[i] := True;
    For i := 2 to 2 * QueensCount do
      NoDiagonal1[i] := True;
    For i := 1 - QueensCount to QueensCount - 1 do
      NoDiagonal2[i] := True;
    if RestoreLastSolution then
    begin
      //If we restore the solution
      //Mark the occupied lines according to the last solution (without the last queen)
      For i := 1 to QueensCount - 1 do
      begin
        NoHorizontal[StrToInt(Need.Solve[i])] := False;
        NoDiagonal1[i + StrToInt(Need.Solve[i])] := False;
        NoDiagonal2[StrToInt(Need.Solve[i]) - i] := False;
      end;
      //In X and Y, the position of the last queen in the solution
      x := QueensCount;
      Y := StrToInt(Need.Solve[QueensCount]);
      //The solution is pushed into the stack (without the last queen)
      For i := 1 to QueensCount - 1 do
        Stack.Push(StrToInt(Need.Solve[i]));
    end
    else
    begin
      x := 1;
      Y := 0;
    end;
    while (x <> 0) and not StopPressed do
    Begin
      If Uspeh Then
      Begin
        Stack.Push(Y);
        If x < QueensCount Then
        Begin
          NoHorizontal[Y] := False;
          NoDiagonal1[x + Y] := False;
          NoDiagonal2[Y - x] := False;
          x := x + 1;
          Y := 0;
        End
        Else
        begin
          frmMain.DrawSolution(Stack);
          Stack.Pop
        End;
      End
      Else
      Begin
        x := x - 1;
        If x > 0 Then
        Begin
          Y := Stack.Pop;
          NoHorizontal[Y] := True;
          NoDiagonal1[x + Y] := True;
          NoDiagonal2[Y - x] := True;
        End;
      End;
    End;
    btnStart.Enabled := True;
    btnByHand.Enabled := True;
    btnContinue.Enabled := True;
End;

procedure TfrmMain.btnStartClick(Sender: TObject);
begin
  SolutionCount := 0;
  lblSolutionCount.Caption := '0';
  StopPressed := False;
  btnStart.Enabled := False;
  btnContinue.Enabled := False;
  btnByHand.Enabled := False;
  case grpSolutionMethod.ItemIndex of
    0:
      RecursiveSolution;
    1:
      StackSolution(False);
  end;
end;

//Filling in the field
procedure TfrmMain.grdChessBoardDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  CellColor: TColor;
begin
  grdChessBoard.Font.Size := 20 + trunc(grdChessBoard.DefaultRowHeight /
    QueensCount) - 1;
  grdChessBoard.Font.Style := [fsBold];
  grdChessBoard.Font.Name := 'Times New Roman';
  with grdChessBoard do
  Begin
    if (ACol = 0) and (ARow >= 1) then
        grdChessBoard.Canvas.TextRect(grdChessBoard.CellRect(ACol, ARow),
          grdChessBoard.CellRect(ACol, ARow).Left, grdChessBoard.CellRect(ACol,
          ARow).Top, IntToStr(QueensCount - ARow + 1))
    else if (ARow = 0) and (ACol >= 1) then
      grdChessBoard.Canvas.TextRect(grdChessBoard.CellRect(ACol, ARow),
        grdChessBoard.CellRect(ACol, ARow).Left, grdChessBoard.CellRect(ACol,
        ARow).Top, char(96 + ACol))
    else if (ACol >= 1) and (ARow >= 1) then
    Begin
      if (Queens[ACol, ARow]) and (Mas[ACol, ARow] <> 2) then
      Begin
        if ((ACol + ARow) mod 2) = 0 then
          CellColor := $9FCEFF
        else
          CellColor := $478BD1;
        Canvas.Brush.Color := CellColor;
        Canvas.FillRect(Rect);
        Canvas.StretchDraw(CellRect(ACol, ARow), img1.Graphic)
      End
      else
      begin
        if Mas[ACol, ARow] = 2 then
          CellColor := $0001BB
        else if (ACol >= 1) and (ARow >= 1) then
          if ((ACol + ARow) mod 2) = 0 then
            CellColor := $9FCEFF
          else
            CellColor := $478BD1;
        Canvas.Brush.Color := CellColor;
        Canvas.FillRect(Rect);
      end;
    End;
  End;
end;

//Turning off the mouse wheel when moving down
procedure TfrmMain.grdChessBoardMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

//Turning off the mouse wheel when moving up
procedure TfrmMain.grdChessBoardMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

//Connecting the "Continue" button when choosing a solution for placing queens through the stack
procedure TfrmMain.grpMethodClick(Sender: TObject);
begin
  //if grpMethod.ItemIndex = 0 then
    //TRadioButton(grpMethod.Controls[1]).Enabled := False;
end;

procedure TfrmMain.grpSolutionMethodClick(Sender: TObject);
begin
  if grpSolutionMethod.ItemIndex = 0 then
  Begin
    btnContinue.Visible := False;
    btnByHand.Top := 374;
    btnHelp.Top := 333;
    grpMethod.Top := 410;
    Image1.Top := 478;
    Image2.Top := 478;
    Image3.Top := 478;
    Image4.Top := 478;
    Image5.Top := 526;
    Image6.Top := 526;
    Image7.Top := 526;
    Image8.Top := 526;
  End
  else
  Begin
    btnContinue.Visible := True;
    btnByHand.Top := 415;
    btnHelp.Top := 374;
    grpMethod.Top := 450;
    Image1.Top := 516;
    Image2.Top := 516;
    Image3.Top := 516;
    Image4.Top := 516;
    Image5.Top := 564;
    Image6.Top := 564;
    Image7.Top := 564;
    Image8.Top := 564;
  End;
end;

//Placing the queen on the chessboard
procedure TfrmMain.grdChessBoardClick(Sender: TObject);
var
  CellColor: TColor;
  i, j, q: Integer;
  FlagF: Boolean;
  Buf1, Buf2, TempV: Integer;
  savedTitle: String;
  Important1, Important2: Boolean;
begin
  Queens[grdChessBoard.Col, grdChessBoard.Row] := not Queens[grdChessBoard.Col,
    grdChessBoard.Row];
  with grdChessBoard do
    if Queens[grdChessBoard.Col, grdChessBoard.Row] then
    begin
      if grpMethod.ItemIndex = 0 then
        TRadioButton(grpMethod.Controls[1]).Enabled := False
      else
        TRadioButton(grpMethod.Controls[0]).Enabled := False;
      FlagF := True;
      if Mas[Col, Row] = 2 then
      Begin
        savedTitle := Application.Title;
        try
          Application.Title := 'Error message';
          ShowMessage('You can''t put a queen on this square!')
        finally
          Application.Title := savedTitle
        end;
        Queens[Col, Row] := not Queens[Col, Row];
      end
      else if (Col >= 1) and (Row >= 1) and (Mas[Col, Row] <> 2) or
        (Mas[Col, Row] = 3) then
      Begin
        Begin
          Mas[Col, Row] := 1;
          (Self.FindComponent('Image' + IntToStr(VisibleQueensCount)) as TImage)
            .Visible := False;
          Dec(VisibleQueensCount);
          if (Col + Row) mod 2 = 0 then
            Canvas.StretchDraw(CellRect(Col, Row), img1.Graphic)
          else
            Canvas.StretchDraw(CellRect(Col, Row), img2.Graphic);
          Inc(Temp);
          if grpMethod.ItemIndex = 0 then
          Begin
            Important1 := False;
            Important2 := False;
            MustHave(Col, Row, Important1, Important2);
          End;
        End;
      End;
    end
    else
    begin
      if Mas[Col, Row] = 2 then
      Begin
        savedTitle := Application.Title;
        try
          Application.Title := 'Error message';
          ShowMessage('You can''t put a queen on this square!')
        finally
          Application.Title := savedTitle
        end;
        CellColor := $0001BB
      End
      else
      begin
        Mas[Col, Row] := 0;
        TempV:=0;
        for q := 1 to QueensCount do
          for j := 1 to QueensCount do
            if Mas[q, j] = 1 then Inc(TempV);
        if TempV<>0 then
          if grpMethod.ItemIndex = 0 then
            TRadioButton(grpMethod.Controls[1]).Enabled := False
          else
            TRadioButton(grpMethod.Controls[0]).Enabled := False
        else
        Begin
          TRadioButton(grpMethod.Controls[1]).Enabled := True;
          TRadioButton(grpMethod.Controls[0]).Enabled := True
        End;
        if grpMethod.ItemIndex = 0 then
        Begin

          Important1 := True;
          Important2 := False;
          MustHave(Col, Row, Important1, Important2);
          for q := 1 to QueensCount do
            for j := 1 to QueensCount do
              if Mas[q, j] = 1 then
              begin
                grdChessBoard.Canvas.Brush.Color := $0001BB;
                for i := 1 to QueensCount do
                Begin
                  if i <> q then
                  Begin
                    grdChessBoard.Canvas.FillRect(CellRect(i, j));
                    Mas[i, j] := 2
                  End;
                  if i <> j then
                  Begin
                    grdChessBoard.Canvas.FillRect(CellRect(q, i));
                    Mas[q, i] := 2
                  End;
                End;
                Buf1 := q;
                Buf2 := j;
                while (Buf1 <> 1) and (Buf2 <> 1) do
                Begin
                  Dec(Buf1);
                  Dec(Buf2);
                End;
                while (Buf1 <= QueensCount) and (Buf2 <= QueensCount) do
                Begin
                  if (Buf1 <> q) and (Buf2 <> j) then
                  Begin
                    grdChessBoard.Canvas.FillRect(CellRect(Buf1, Buf2));
                    Mas[Buf1, Buf2] := 2
                  End;
                  Inc(Buf1);
                  Inc(Buf2);
                End;

                Buf1 := q;
                Buf2 := j;
                while (Buf1 <> 1) and (Buf2 <> QueensCount) do
                Begin
                  Dec(Buf1);
                  Inc(Buf2);
                End;
                while (Buf1 <= QueensCount) and (Buf2 >= 1) do
                Begin
                  if (Buf1 <> q) and (Buf2 <> j) then
                  Begin
                    grdChessBoard.Canvas.FillRect(CellRect(Buf1, Buf2));
                    Mas[Buf1, Buf2] := 2
                  End;
                  Inc(Buf1);
                  Dec(Buf2);
                End;
              end;
        End;

        if ((Col + Row) mod 2) = 0 then
          CellColor := $9ECFFF
        else
          CellColor := $478BD1;
      end;

      grdChessBoard.Canvas.Brush.Color := CellColor;
      grdChessBoard.Canvas.FillRect(CellRect(Col, Row));
      Inc(VisibleQueensCount);
      (Self.FindComponent('Image' + IntToStr(VisibleQueensCount)) as TImage)
        .Visible := True;
      Dec(Temp);
    end;
  if Temp = QueensCount then
  Begin
    grdChessBoard.Enabled := False;
    Check;
  End;
  if Temp <> QueensCount then
  begin
    for i := 1 to QueensCount do
      for j := 1 to QueensCount do
        if Mas[i, j] = 0 then
          FlagF := False;
    if (CountForCorrect > QueensCount * (QueensCount - 1)) and FlagF then
      Correct;
  end;
end;

//Leaving the colored red cells when removing the queen in the mode of placing queens manually with hints
procedure TfrmMain.MustHave(Col, Row: Integer;
  var Important1, Important2: Boolean);
var
  i: Integer;
  CellColor: TColor;
  Buf1, Buf2: Integer;
begin
  with grdChessBoard do
  Begin
    for i := 1 to QueensCount do
    Begin
      grdChessBoard.Canvas.Brush.Color := $0001BB;
      if i <> Col then
      Begin
        if Important1 then
        Begin
          if ((i + Row) mod 2) = 0 then
            CellColor := $9ECFFF
          else
            CellColor := $478BD1;
          grdChessBoard.Canvas.Brush.Color := CellColor;
          Mas[i, Row] := 0
        End
        else
        Begin
          Inc(CountForCorrect);
          Mas[i, Row] := 2
        End;
        grdChessBoard.Canvas.FillRect(CellRect(i, Row));
      End;
      if i <> Row then
      Begin
        if Important1 then
        Begin
          if ((Col + i) mod 2) = 0 then
            CellColor := $9ECFFF
          else
            CellColor := $478BD1;
          grdChessBoard.Canvas.Brush.Color := CellColor;
          Mas[Col, i] := 0
        End
        else
        Begin
          Inc(CountForCorrect);
          Mas[Col, i] := 2
        End;
        grdChessBoard.Canvas.FillRect(CellRect(Col, i));
      End;
    End;
    Buf1 := Col;
    Buf2 := Row;
    while (Buf1 <> 1) and (Buf2 <> 1) do
    Begin
      Dec(Buf1);
      Dec(Buf2);
    End;
    while (Buf1 <= QueensCount) and (Buf2 <= QueensCount) do
    Begin
      if (Buf1 <> Col) and (Buf2 <> Row) then
      Begin
        if Important1 then
        Begin
          if ((Buf1 + Buf2) mod 2) = 0 then
            CellColor := $9ECFFF
          else
            CellColor := $478BD1;
          grdChessBoard.Canvas.Brush.Color := CellColor;
          Mas[Buf1, Buf2] := 0
        End
        else
        Begin
          Inc(CountForCorrect);
          Mas[Buf1, Buf2] := 2
        End;
        grdChessBoard.Canvas.FillRect(CellRect(Buf1, Buf2));
      End;
      Inc(Buf1);
      Inc(Buf2);
    End;

    Buf1 := Col;
    Buf2 := Row;
    while (Buf1 <> 1) and (Buf2 <> QueensCount) do
    Begin
      Dec(Buf1);
      Inc(Buf2);
    End;
    while (Buf1 <= QueensCount) and (Buf2 >= 1) do
    Begin
      if (Buf1 <> Col) and (Buf2 <> Row) then
      Begin
        if Important1 then
        Begin
          if ((Buf1 + Buf2) mod 2) = 0 then
            CellColor := $9ECFFF
          else
            CellColor := $478BD1;
          grdChessBoard.Canvas.Brush.Color := CellColor;
          Mas[Buf1, Buf2] := 0
        End
        else
        Begin
          Inc(CountForCorrect);
          Mas[Buf1, Buf2] := 2
        End;
        grdChessBoard.Canvas.FillRect(CellRect(Buf1, Buf2));
      End;
      Inc(Buf1);
      Dec(Buf2);
    End;
  End;
end;

//Checking the correct placement of queens and displaying the subsequent message(with hints)
procedure TfrmMain.Correct;
var
  i, j: Integer;
  buttonSelected: Integer;
begin
  if CountForCorrect <> QueensCount * QueensCount then
  with CreateMessageDialog('Unfortunately, you did not place all the queens with hints. Do you want to try again?', mtInformation, [mbYes, mbNo]) do
  begin
    DeleteMenu(GetSystemMenu(Handle, False), SC_CLOSE, MF_BYCOMMAND);
  if ShowModal = mrYes then
  Begin
    grdChessBoard.Enabled := True;
    for i := 1 to QueensCount do
      for j := 1 to QueensCount do
        Mas[i, j] := 0;
    for i := 1 to QueensCount do
      for j := 1 to QueensCount do
        if Queens[i, j] then
          Queens[i, j] := not Queens[i, j];
    TRadioButton(grpMethod.Controls[1]).Enabled := True;
    TRadioButton(grpMethod.Controls[0]).Enabled := True;
    VisibleQueensCount := QueensCount;
    Temp := 0;
    Image1.Visible := True;
    Image2.Visible := True;
    Image3.Visible := True;
    Image4.Visible := True;
    Drawing;
    grdChessBoard.Repaint;
    CountForCorrect := 0;
  End
  else
  Begin
    for i := 1 to QueensCount do
      for j := 1 to QueensCount do
      Begin
        Mas[i, j] := 3;
        Queens[i, j] := False;
      End;
    grdChessBoard.Enabled := False;
    grdChessBoard.Repaint;
    Image1.Visible := False;
    Image2.Visible := False;
    Image3.Visible := False;
    Image4.Visible := False;
    Image5.Visible := False;
    Image6.Visible := False;
    Image7.Visible := False;
    Image8.Visible := False;
    TRadioButton(grpMethod.Controls[1]).Enabled := True;
    TRadioButton(grpMethod.Controls[0]).Enabled := True;
    grpMethod.Visible := False;
    btnByHand.Enabled := False;
    btnStart.Enabled := True;
    btnStop.Enabled := True;
  End;
  end;

end;

//Checking the correct placement of queens and displaying the subsequent message(without hints)
procedure TfrmMain.Check;
var
  i, q: Integer;
  j, f: Integer;
  Temp1, Temp2: Integer;
  Flag, FlagPos: Boolean;
  buttonSelected: Integer;
  CellColor: TColor;
begin

  i := 1;
  Flag := True;
  FlagPos := True;
  while (i <= QueensCount) and Flag do
  Begin
    j := 1;
    Temp1 := 0;
    Temp2 := 0;
    while (j <= QueensCount) and Flag do
    Begin
      if Mas[i, j] = 1 then
        Inc(Temp1);
      if Mas[j, i] = 1 then
        Inc(Temp2);
      Inc(j);
      if (Temp1 >= 2) or (Temp2 >= 2) then
        Flag := False;
    End;
    Inc(i);
  End;

  i := 1;
  if FlagPos then
    while (i <= QueensCount) and Flag do
    Begin
      j := 1;
      Temp1 := 0;
      while (j <= QueensCount) and Flag do
      Begin
        if Mas[i, j] = 1 then
        Begin
          for q := 1 to QueensCount do
            for f := 1 to QueensCount do
              if (Mas[q, f] = 1) and (abs(i - q) = abs(j - f)) then
                Inc(Temp1);
        End;
        Inc(j);
        if Temp1 >= 2 then
          Flag := False;
      End;
      if Temp1 >= 2 then
        Flag := False;
      Inc(i);
    End;
  if (not Flag) and FlagPos then
  with CreateMessageDialog('You have placed all the queens incorrectly. Do you want to try again?', mtInformation, [mbYes, mbNo]) do
  begin
    DeleteMenu(GetSystemMenu(Handle, False), SC_CLOSE, MF_BYCOMMAND);
  if ShowModal = mrYes then
  Begin
    TRadioButton(grpMethod.Controls[1]).Enabled := True;
    TRadioButton(grpMethod.Controls[0]).Enabled := True;
    grdChessBoard.Enabled := True;
    for i := 1 to MaxQueensCount do
      for j := 1 to MaxQueensCount do
        if Mas[i, j] = 1 then
          Mas[i, j] := 0;
    for i := 1 to MaxQueensCount do
      for j := 1 to MaxQueensCount do
        if Queens[i, j] then
          Queens[i, j] := not Queens[i, j];
    VisibleQueensCount := 0;
    Image1.Visible := True;
    Image2.Visible := True;
    Image3.Visible := True;
    Image4.Visible := True;
    Drawing;
    VisibleQueensCount := QueensCount;
    Temp := 0;
    grdChessBoard.Repaint;
    CountForCorrect := 0;
  End
  else
  Begin
    for i := 1 to MaxQueensCount do
      for j := 1 to MaxQueensCount do
        Queens[i, j] := False;
    Image1.Visible := False;
    Image2.Visible := False;
    Image3.Visible := False;
    Image4.Visible := False;
    Image5.Visible := False;
    Image6.Visible := False;
    Image7.Visible := False;
    Image8.Visible := False;
    grdChessBoard.Repaint;
    TRadioButton(grpMethod.Controls[1]).Enabled := True;
    TRadioButton(grpMethod.Controls[0]).Enabled := True;
    grpMethod.Visible := False;
    btnByHand.Enabled := False;
    btnStart.Enabled := True;
    btnStop.Enabled := True;
  End;
  end;

  if (Flag) and (FlagPos) then
  with CreateMessageDialog('Congratulations! You have placed all the queens absolutely correctly! Do you want to try again?', mtInformation, [mbYes, mbNo]) do
  begin
    DeleteMenu(GetSystemMenu(Handle, False), SC_CLOSE, MF_BYCOMMAND);
  if ShowModal = mrYes then
  Begin
    TRadioButton(grpMethod.Controls[1]).Enabled := True;
    TRadioButton(grpMethod.Controls[0]).Enabled := True;
    grdChessBoard.Enabled := True;
    for i := 1 to MaxQueensCount do
      for j := 1 to MaxQueensCount do
        if Mas[i, j] = 1 then
          Mas[i, j] := 0;
    for i := 1 to MaxQueensCount do
      for j := 1 to MaxQueensCount do
        if Queens[i, j] then
          Queens[i, j] := not Queens[i, j];
    if grpMethod.ItemIndex = 0 then

      for i := 1 to QueensCount do
        for j := 1 to QueensCount do
          Mas[i, j] := 0;
    VisibleQueensCount := 0;
    Image1.Visible := True;
    Image2.Visible := True;
    Image3.Visible := True;
    Image4.Visible := True;
    Drawing;
    VisibleQueensCount := QueensCount;
    Temp := 0;
    grdChessBoard.Repaint;
    CountForCorrect := 0;
  End
  else
  Begin
    for i := 1 to MaxQueensCount do
      for j := 1 to MaxQueensCount do
        if Mas[i, j] = 1 then
          Mas[i, j] := 0;
    for i := 1 to MaxQueensCount do
      for j := 1 to MaxQueensCount do
        if Queens[i, j] then
          Queens[i, j] := not Queens[i, j];
    if grpMethod.ItemIndex = 0 then

      for i := 1 to QueensCount do
        for j := 1 to QueensCount do
          Mas[i, j] := 0;
    Image1.Visible := False;
    Image2.Visible := False;
    Image3.Visible := False;
    Image4.Visible := False;
    grpMethod.Visible := False;
    btnByHand.Enabled := False;
    btnStart.Enabled := True;
    btnStop.Enabled := True;
    //Drawing;
    grdChessBoard.Repaint;
    TRadioButton(grpMethod.Controls[1]).Enabled := True;
    TRadioButton(grpMethod.Controls[0]).Enabled := True;
  End;
  end;

end;

//Stopping the demonstration of solutions
procedure TfrmMain.btnStopClick(Sender: TObject);
begin
  btnStart.Enabled := True;
  btnContinue.Enabled := True;
  StopPressed := True;
end;

//Placing queens manually
procedure TfrmMain.btnByHandClick(Sender: TObject);
Var
  i, j: Integer;
begin
  Inc(ForCount);
  lblSolutionCount.Caption := '0';
  btnStart.Enabled := False;
  btnStop.Enabled := False;
  btnContinue.Enabled := False;
  for i := 1 to QueensCount do
    for j := 1 to QueensCount do
      Queens[i, j] := False;
  grdChessBoard.Repaint;
  if ForCount mod 2 = 0 then
  Begin
    VisibleFlag := True;
    grpMethod.Visible := True;
    grdChessBoard.Enabled := True;
    Image1.Picture.LoadFromFile('Ферзь.png');
    Image2.Picture.LoadFromFile('Ферзь.png');
    Image3.Picture.LoadFromFile('Ферзь.png');
    Image4.Picture.LoadFromFile('Ферзь.png');
    Image1.Visible := True;
    Image2.Visible := True;
    Image3.Visible := True;
    Image4.Visible := True;
    Drawing;
    grpSolutionMethod.Enabled := False;
  End
  else
  Begin
    btnStart.Enabled := True;
    btnStop.Enabled := True;
    grdChessBoard.Enabled := False;
    btnContinue.Enabled := True;
    Image1.Picture := Nil;
    Image2.Picture := Nil;
    Image3.Picture := Nil;
    Image4.Picture := Nil;
    if QueensCount >= 5 then
      Image5.Picture := Nil;
    if QueensCount >= 6 then
      Image6.Picture := Nil;
    if QueensCount >= 7 then
      Image7.Picture := Nil;
    if QueensCount = 8 then
      Image8.Picture := Nil;
    VisibleFlag := False;
    grpMethod.Visible := False;
    grpSolutionMethod.Enabled := True;
  End;
end;

//Continue demonstrating solutions
procedure TfrmMain.btnContinueClick(Sender: TObject);
begin
  StopPressed := False;
  btnStart.Enabled := False;
  btnByHand.Enabled := False;
  StackSolution(True);
end;

//Viewing help
procedure TfrmMain.btnHelpClick(Sender: TObject);
begin
  Need.Help := 'The help has been viewed';
  frmHelp.Show;
end;

//Drawing a basket of queens
procedure TfrmMain.Drawing;
begin
  if QueensCount = MaxQueensCount / 2 then
    Image5.Picture := Nil
  else
  Begin
    Image5.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) +
      'Ферзь.png');
    Image5.Visible := True;
  End;

  if (QueensCount = 5) or (QueensCount = 4) then
    Image6.Picture := Nil
  else
  Begin
    Image6.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) +
      'Ферзь.png');
    Image6.Visible := True;
  End;

  if (QueensCount <= 6) and (QueensCount >= 4) then
    Image7.Picture := Nil
  else
  Begin
    Image7.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) +
      'Ферзь.png');
    Image7.Visible := True;
  End;

  if (QueensCount <= 7) and (QueensCount >= 4) then
    Image8.Picture := Nil
  else
  Begin
    Image8.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) +
      'Ферзь.png');
    Image8.Visible := True;
  End;
end;

//Rendering the found solution(for recursion)
procedure TfrmMain.DrawSolution(Solution: array of Integer);
var
  i: Integer;
  CurrentTickCount: Integer;
  HelpString: String;
begin
  SolutionCount := SolutionCount + 1;
  lblSolutionCount.Caption := IntToStr(SolutionCount);
  grdChessBoard.Repaint;
  for i := 1 to QueensCount do
  Begin
    Need.Solve := Need.Solve + IntToStr(Solution[i - 1]);
    with grdChessBoard do
      if (i - 1 + Solution[i - 1] - 1) mod 2 = 0 then
        Canvas.StretchDraw(CellRect(i, Solution[i - 1]), img1.Graphic)
      else
        Canvas.StretchDraw(CellRect(i, Solution[i - 1]), img2.Graphic);
  End;
  Assignfile(Input,'Placements.txt');
  Append(Input);
  writeln(Input, 'Placement № ', SolutionCount);
  if QueensCount div 10 = 1 then
  Begin
    while Length(HelpString) < ((QueensCount - 1) * 3 + QueensCount - 2 +
      QueensCount mod 10) do
      HelpString := '-' + HelpString;
    writeln(Input, HelpString)
  End
  else
  Begin
    while Length(HelpString) < ((QueensCount - 1) * 3 + QueensCount - 2) do
      HelpString := '-' + HelpString;
    writeln(Input, HelpString)
  End;
  for i := 1 to QueensCount - 1 do
  begin
    Write(Input, char(ord(96 + Solution[i - 1])), '-', QueensCount - i);
    if i <> QueensCount - 1 then
      write(Input, ',');
  end;
  writeln(Input);
  writeln(Input, HelpString);
  Closefile(Input);
  CurrentTickCount := GetTickCount;
  Repeat
    Application.ProcessMessages
  Until (GetTickCount - CurrentTickCount) > ShowDelay end;

//Rendering the found solution(for stack)
procedure TfrmMain.DrawSolution(Solution: TStack<Integer>);
var
  i: Integer;
  CurrentTickCount: cardinal;
  SolutionArray: TArray<Integer>;
  HelpString: String;
begin
  SolutionCount := SolutionCount + 1;
  lblSolutionCount.Caption := IntToStr(SolutionCount);
  grdChessBoard.Repaint;
  grdChessBoard.Canvas.Brush.Color := clBlack;
  SolutionArray := Solution.ToArray;
  Need.Solve := '';
  for i := 1 to QueensCount do
  Begin
    Need.Solve := Need.Solve + IntToStr(SolutionArray[i - 1]);
    with grdChessBoard do
      if (i + SolutionArray[i - 1]) mod 2 = 0 then
        Canvas.StretchDraw(CellRect(i, SolutionArray[i - 1]), img1.Graphic)
      else
        Canvas.StretchDraw(CellRect(i, SolutionArray[i - 1]), img2.Graphic);
  End;
  Assignfile(Input,'Placements.txt');
  Append(Input);
  writeln(Input, 'Placement № ', SolutionCount);
  if QueensCount div 10 = 1 then
  Begin
    while Length(HelpString) < ((QueensCount - 1) * 3 + QueensCount - 2 +
      QueensCount mod 10) do
        HelpString := '-' + HelpString;
      writeln(Input, HelpString)
  End
  else
  Begin
    while Length(HelpString) < ((QueensCount - 1) * 3 + QueensCount - 2) do
      HelpString := '-' + HelpString;
    writeln(Input, HelpString)
  End;
  for i := 1 to QueensCount - 1 do
  begin
    Write(Input, char(ord(96 + SolutionArray[i - 1])), '-', QueensCount - i);
    if i <> QueensCount - 1 then
      write(Input, ',');
  end;
  writeln(Input);
  writeln(Input, HelpString);
  Closefile(Input);

  CurrentTickCount := GetTickCount;
  Repeat
    Application.ProcessMessages
  Until (GetTickCount - CurrentTickCount) > ShowDelay
end;

//Checking for the boundaries of the input interval
procedure TfrmMain.edtShowDelayKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
begin
  if Key = 13 then
    if edtShowDelay.Value > 400 then
      MessageDlg('The interval must be <= 400 (in ms)', mtError,[mbOk], 0)
    else if edtShowDelay.Value < 10 then
      MessageDlg('The interval must be >= 10 (in ms)', mtError,[mbOk], 0)
end;

//Checking for the limits of the number of queens to be entered
procedure TfrmMain.edtQueensCountChangeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
begin
  if Key = 13 then
    if edtQueensCount.Value > 8 then
      MessageDlg('The board size must be <= 8', mtError,[mbOk], 0)
    else if edtQueensCount.Value < 4 then
      MessageDlg('The board size must be >= 4', mtError,[mbOk], 0)
end;

//Changing the number of queens
procedure TfrmMain.edtQueensCountChange(Sender: TObject);
var
  I, j: Integer;
begin
  btnStart.Enabled := True;
  btnStop.Enabled := True;
  btnByHand.Enabled := True;
  if (edtQueensCount.Value > MaxQueensCount) or (edtQueensCount.Value < 4) then
    QueensCount := MaxQueensCount + 1
  else
    QueensCount := edtQueensCount.Value + 1;
  ShowDelay := edtShowDelay.Value;
  SolutionCount := 0;
  lblSolutionCount.Caption := '0';
  with grdChessBoard do
    begin
      ColCount := QueensCount;
      RowCount := QueensCount;
      DefaultColWidth := trunc((Width - QueensCount - 1) / QueensCount);
      DefaultRowHeight := trunc((Height - QueensCount - 1) / QueensCount);
      if (edtQueensCount.Value >= MaxQueensCount) or (edtQueensCount.Value < 4) then
        QueensCount := MaxQueensCount
      else
        QueensCount := edtQueensCount.Value;
      Repaint;
    end;
  grdChessBoard.Enabled := True;
  Temp := 0;
  for I := 1 to QueensCount do
    for j := 1 to QueensCount do
      Mas[I, j] := 0;
  Image1.Visible := False;
  Image2.Visible := False;
  Image3.Visible := False;
  Image4.Visible := False;
  Image5.Visible := False;
  Image6.Visible := False;
  Image7.Visible := False;
  Image8.Visible := False;
  grdChessBoard.Enabled := False;
  VisibleQueensCount := QueensCount;
  grpMethod.Visible := False;
  ForCount := 1;
End;

//Changing the interval
procedure TfrmMain.edtShowDelayChange(Sender: TObject);
begin
  ShowDelay := edtShowDelay.Value;
end;

//Closing the form
procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  StopPressed := True;
end;

//Creating a form
procedure TfrmMain.FormCreate(Sender: TObject);
var
  I, j: Integer;
begin
  DoubleBuffered := True;
  QueensCount := 8;
  ShowDelay := 300;
  SolutionCount := 0;
  ForCount := 1;
  StopPressed := False;
  edtQueensCount.MaxValue := MaxQueensCount;
  edtQueensCount.MinValue := 4;
  edtQueensCount.Value := 8;
  for I := 1 to MaxQueensCount do
    for j := 1 to MaxQueensCount do
      Queens[I, j] := False;
  img1 := TPicture.Create;
  img1.LoadFromFile('Ферзь.png');
  img2 := TPicture.Create;
  img2.LoadFromFile('Ферзь.png');
  CountForCorrect := 0;
  VisibleQueensCount := QueensCount;
  grpMethod.Visible := False;
  btnContinue.Visible := False;
  btnByHand.Top := 374;
  btnHelp.Top := 333;
  grpMethod.Top := 410;
  Image1.Top := 478;
  Image2.Top := 478;
  Image3.Top := 478;
  Image4.Top := 478;
  Image5.Top := 526;
  Image6.Top := 526;
  Image7.Top := 526;
  Image8.Top := 526;
  grdChessBoard.Enabled := False;
  Assignfile(TypedFile, 'MyTypedFile.dat');

  //Opening the file for recording
  Rewrite(TypedFile);
  Assignfile(Input, 'Placements.txt');
  Rewrite(Input);
  Need.Help := 'The help hasn''t been viewed';
  Closefile(Input);
end;

end.
