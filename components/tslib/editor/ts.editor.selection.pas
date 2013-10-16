{
  Copyright (C) 2013 Tim Sinaeve tim.sinaeve@gmail.com

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

unit ts.Editor.Selection;

{$MODE Delphi}

interface

uses
  Classes,

  SynEdit, SynEditTypes,

  ts.Editor.Interfaces;

type

  { TEditorSelection }

  TEditorSelection = class(TInterfacedObject, IEditorSelection)
  private
    FBlockBegin    : TPoint;
    FBlockEnd      : TPoint;
    FLines         : TStrings;
    FSelectionMode : TSynSelectionMode;
    FLockUpdates   : Boolean;
    FStripLastLine : Boolean;
    FCaretXY       : TPoint;
    FEditorView    : IEditorView;

    function GetBlockBegin: TPoint;
    function GetBlockEnd: TPoint;
    function GetCaretXY: TPoint;
    function GetLines: TStrings;
    function GetSelectionMode: TSynSelectionMode;
    function GetText: string;
    procedure SetBlockBegin(AValue: TPoint);
    procedure SetBlockEnd(AValue: TPoint);
    procedure SetCaretXY(AValue: TPoint);
    procedure SetSelectionMode(AValue: TSynSelectionMode);
    procedure SetText(AValue: string);

  protected
    property LockUpdates: Boolean
      read FLockUpdates write FLockUpdates;

    property StripLastLine: Boolean
      read FStripLastLine write FStripLastLine;

  public
    constructor Create(AEditorView: IEditorView); reintroduce; virtual;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure Clear;
    procedure Store(
      ALockUpdates           : Boolean = True;
      AAutoExcludeEmptyLines : Boolean = False
    );
    procedure Restore;
    procedure Ignore;

    property BlockBegin: TPoint
      read GetBlockBegin write SetBlockBegin;

    property BlockEnd: TPoint
      read GetBlockEnd write SetBlockEnd;

    property CaretXY: TPoint
      read GetCaretXY write SetCaretXY;

    property SelectionMode: TSynSelectionMode
      read GetSelectionMode write SetSelectionMode;

    property Lines: TStrings
      read GetLines;

    property Text: string
      read GetText write SetText;

  end;

implementation

uses
  ts.Editor.Utils;

{$region 'construction and destruction' /fold}
constructor TEditorSelection.Create(AEditorView: IEditorView);
begin
  inherited Create;
  FEditorView := AEditorView;
end;

procedure TEditorSelection.AfterConstruction;
begin
  inherited AfterConstruction;
  FLines := TStringList.Create;
end;

procedure TEditorSelection.BeforeDestruction;
begin
  FLines.Free;
  inherited BeforeDestruction;
end;
{$endregion}

{$region 'property access mehods' /fold}
function TEditorSelection.GetBlockBegin: TPoint;
begin
  Result := FBlockBegin;
end;

procedure TEditorSelection.SetBlockBegin(AValue: TPoint);
begin
  FBlockBegin := AValue;
end;

function TEditorSelection.GetBlockEnd: TPoint;
begin
  Result := FBlockEnd;
end;

function TEditorSelection.GetCaretXY: TPoint;
begin
  Result := FCaretXY;
end;

procedure TEditorSelection.SetCaretXY(AValue: TPoint);
begin
  FCaretXY := AValue;
end;

function TEditorSelection.GetLines: TStrings;
begin
  Result := FLines;
end;

procedure TEditorSelection.SetBlockEnd(AValue: TPoint);
begin
  FBlockEnd := AValue;
end;

function TEditorSelection.GetSelectionMode: TSynSelectionMode;
begin
  Result := FSelectionMode;
end;

function TEditorSelection.GetText: string;
begin
  // The Text property of a stringlist always returns a line ending at the end
  // of the string which needs to be removed to avoid side effects.
  Result := StripLastLineEnding(FLines.Text);
end;

procedure TEditorSelection.SetText(AValue: string);
begin
  FLines.Text := AValue;
end;

procedure TEditorSelection.SetSelectionMode(AValue: TSynSelectionMode);
begin
  FSelectionMode := AValue;
end;
{$endregion}

{$region 'public methods' /fold}
procedure TEditorSelection.Clear;
begin
  FLines.Clear;
  FBlockBegin.X  := 0;
  FBlockBegin.Y  := 0;
  FBlockEnd.X    := 0;
  FBlockEnd.Y    := 0;
  FSelectionMode := smNormal;
end;

{
  Saves information about the selected block to be able to maintain the
  selection if some modification happens on the selected text.

  ALockUpdates
    Determines if BeginUpdate/EndUpdate should be called in combination with
    StoreBlock/RestoreBlock

  AAutoExcludeEmptyLines
    Determines if the last line in a multiline selection should be included if
    it is empty.
}

procedure TEditorSelection.Store(ALockUpdates: Boolean;
  AAutoExcludeEmptyLines: Boolean);
begin
  FBlockBegin    := FEditorView.BlockBegin;
  FBlockEnd      := FEditorView.BlockEnd;
  FSelectionMode := FEditorView.SelectionMode;
  FLines.Text    := FEditorView.SelText;
  FLockUpdates   := ALockUpdates;
  if FLockUpdates then
    FEditorView.Editor.BeginUpdate;

  if AAutoExcludeEmptyLines then
  begin
    // Are multiple lines selected and is the last line in selection empty?
    // => adjust selected block to exclude this line
    if (FBlockEnd.X = 1)
      and (FBlockEnd.Y > FBlockBegin.Y)
      and not (FSelectionMode in [smLine, smColumn]) then
    begin
      FBlockEnd.Y := FBlockEnd.Y - 1;
      FStripLastLine := True;
    end
    else
      FStripLastLine := False;
  end
  else
    FStripLastLine := True;
end;

{

  FStoredBlockBegin is always left untouched.

Depending on the selectionmode RestoreBlock will select code as follows:

   smNormal
     FStoredBlockEnd.X => charcount of the last line in FStoredBlockLines
     FStoredBlockEnd.Y => FStoredBlockBegin.Y + FStoredBlockLines.Count

   smColumn
     FStoredBlockEnd.X => FStoredBlockBegin.X + charcount of longest line in FStoredBlockLines
     FStoredBlockEnd.Y => StoredBlockBegin.Y + FStoredBlockLines.Count
}


procedure TEditorSelection.Restore;
begin
  if StripLastLine then // adjust block selection bounds
  begin
    case SelectionMode of
    smNormal:
      begin
        FBlockEnd.X := Length(FLines[FLines.Count - 1]) + 2;
        FBlockEnd.Y := FBlockBegin.Y + FLines.Count - 1;
      end;
    smColumn:
      begin
        FBlockEnd.X := Length(FLines[FLines.Count - 1]) + 2;
        FBlockEnd.Y := FBlockBegin.Y + FLines.Count - 1;
      end;
    smLine:
      begin

      end;
    end;
  end;
  FEditorView.Editor.SetTextBetweenPoints(
    BlockBegin,
    BlockEnd,
    Text,
    [setSelect],
    scamIgnore,
    smaKeep,
    SelectionMode
  );
  if FLockUpdates then
    FEditorView.Editor.EndUpdate;
end;

procedure TEditorSelection.Ignore;
begin
  if FLockUpdates then
    FEditorView.Editor.EndUpdate;
  Clear;
end;
{$endregion}

end.
