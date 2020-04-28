Unit Unit1;

Interface

Uses
  Windows, Classes, Graphics, Controls, Forms, ExtCtrls, Math, StdCtrls,
  SysUtils, Clipbrd;

Type
  TForm1 = Class(TForm)
    Panel1: TPanel;
    edtRD: TEdit;
    edtRH: TEdit;
    edtGD: TEdit;
    edtGH: TEdit;
    edtBD: TEdit;
    edtBH: TEdit;
    edtRGB: TEdit;
    edtHTML: TEdit;
    lblHex: TLabel;
    lblDec: TLabel;
    lblHx: TLabel;
    btnCopyRGB: TButton;
    btnCopyHTML: TButton;
    Label1: TLabel;
    edtHEX: TEdit;
    btnCopyHEX: TButton;
    edtC: TEdit;
    edtM: TEdit;
    edtY: TEdit;
    edtK: TEdit;
    lblRed: TLabel;
    lblGreen: TLabel;
    lblBlue: TLabel;
    lblRGB: TLabel;
    lblC: TLabel;
    lblM: TLabel;
    lblY: TLabel;
    lblK: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblDrag: TLabel;
    Procedure FormPaint(Sender: TObject);
    Procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    Procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    Procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    Procedure GetColour();
    Procedure btnCopyRGBClick(Sender: TObject);
    Procedure btnCopyHTMLClick(Sender: TObject);
    Procedure btnCopyHEXClick(Sender: TObject);
  Private
    FCaptured: Boolean;
  Public
    { Public declarations }
  End;

//Type
//  THSV = Record  // hue saturation value (HSV)
//    Hue, Sat, Val: Double;
//  End;

Var
  Form1: TForm1;

Implementation

{$R *.dfm}
{$X+}
//{$H+}

Const  // the first item, the place where the crosshair is
  ClickRect: TRect = (
    Left: 10;
    Top: 10;
    Right: 50;
    Bottom: 50
  );

Function DesktopColor(Const X, Y: Integer): TColor;
Var
  c: TCanvas;
Begin
  c := TCanvas.Create;
  Try
    c.Handle := GetWindowDC(GetDesktopWindow);
    Result := GetPixel(c.Handle, X, Y);
  Finally
    c.Free;
  End;
End;

Procedure TForm1.FormPaint(Sender: TObject);
Begin
  //Draw the control and the crosshair if no capturing
  If GetCapture <> Handle Then
  Begin
    DrawFrameControl(Canvas.Handle, ClickRect, 0, DFCS_BUTTONPUSH);
    DrawIcon(Canvas.Handle, ClickRect.Left, ClickRect.Top, Screen.Cursors[crCross]);
  End;
End;

Procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Begin
  If (Button = mbLeft) And (Shift = [ssLeft]) And PtInRect(ClickRect, Point(X, Y)) Then
  Begin
    DrawFrameControl(Canvas.Handle, ClickRect, 0, DFCS_PUSHED);
    FCaptured := True;
    SetCapture(Handle);
    Screen.Cursor := crCross;
  End;
End;

Procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Begin
  If FCaptured Then
  Begin
    FCaptured := False;
    ReleaseCapture;
    InvalidateRect(Handle, @ClickRect, False);
    Screen.Cursor := crDefault;
  End;
End;

Procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
Begin
  If FCaptured Then
    GetColour;
End;

Procedure TForm1.GetColour();
Var
  Pos: TPoint;
  ThisColour: TColor;
  R, G, B, C, M, Y, K: Integer;
  Rp, Gp, Bp, Kp: Single;
Begin
  GetCursorPos(Pos);
  ThisColour := DesktopColor(Pos.X, Pos.Y);
  Panel1.Color := ThisColour;
  R := ThisColour And $FF;
  G := (ThisColour And $FF00) Shr 8;
  B := (ThisColour And $FF0000) Shr 16;
  Rp := R / 255;
  Gp := G / 255;
  Bp := B / 255;
  Kp := 1 - Max(Rp, Max(Gp, Bp));
  K := Round(100 * Kp);
  If (Kp = 1) Then
  Begin
    C := 0;
    M := 0;
    Y := 0;
  End
  Else
  Begin
    C := Round(100 * (1 - Rp - Kp) / (1 - Kp));
    M := Round(100 * (1 - Gp - Kp) / (1 - Kp));
    Y := Round(100 * (1 - Bp - Kp) / (1 - Kp));
  End;
  edtRD.Text := IntToStr(R);
  edtRH.Text := IntToHex(R, 2);
  edtGD.Text := IntToStr(G);
  edtGH.Text := IntToHex(G, 2);
  edtBD.Text := IntToStr(B);
  edtBH.Text := IntToHex(B, 2);
  edtC.Text := IntToStr(C);
  edtM.Text := IntToStr(M);
  edtY.Text := IntToStr(Y);
  edtK.Text := IntToStr(K);
  edtRGB.Text := 'RGB(' + edtRD.Text + ', ' + edtGD.Text + ', ' + edtBD.Text + ')';
  edtHTML.Text := '#' + edtRH.Text + edtGH.Text + edtBH.Text;
  edtHEX.Text := edtBH.Text + edtGH.Text + edtRH.Text;

End;

Procedure TForm1.btnCopyRGBClick(Sender: TObject);
Begin
  Clipboard.AsText := edtRGB.Text;
End;

Procedure TForm1.btnCopyHTMLClick(Sender: TObject);
Begin
  Clipboard.AsText := edtHTML.Text;
End;

Procedure TForm1.btnCopyHEXClick(Sender: TObject);
Begin
  Clipboard.AsText := edtHEX.Text;
End;

End.

