program DevilHunter;

uses
  Windows,
  DGLE2 in '..\..\..\Engines\DGLE 2 Engine\Include\Delphi\DGLE2.pas',
  DGLE2_EXT in '..\..\..\Engines\DGLE 2 Engine\Include\Delphi\DGLE2_EXT.pas',
  DGLE2_types in '..\..\..\Engines\DGLE 2 Engine\Include\Delphi\DGLE2_types.pas',
  SubSystems in 'src\SubSystems.pas',
  Resources in 'src\Resources.pas',
  Settings in 'src\Settings.pas',
  Convert in 'src\Convert.pas',
  Camera in 'src\Camera.pas',
  Input in 'src\Input.pas',
  Game in 'src\Game.pas',
  Map in 'src\Map.pas',
  Creature in 'src\Creature.pas',
  Creature.Mob in 'src\Creature.Mob.pas',
  Creature.Player in 'src\Creature.Player.pas',
  Item in 'src\Item.pas',
  Item.Weapon in 'src\Items\Item.Weapon.pas',
  Rune in 'src\Rune.pas',
  Runeword in 'src\Runeword.pas',
  Skill in 'src\Skill.pas',
  Skill.Shokwave in 'src\Skills\Skill.Shokwave.pas',
  Skill.Fireball in 'src\Skills\Skill.Fireball.pas',
  UI in 'src\UI.pas',
  UI.Component in 'src\UI\UI.Component.pas',
  UI.Window in 'src\UI\UI.Window.pas',
  UI.Grid in 'src\UI\UI.Grid.pas',
  Bag in 'src\Bag.pas',
  UI.Panel in 'src\UI\UI.Panel.pas',
  RunePage in 'src\RunePage.pas',
  Sound in 'src\Sound.pas',
  UI.Button in 'src\UI\UI.Button.pas',
  UI.Caption in 'src\UI\UI.Caption.pas',
  UI.Image in 'src\UI\UI.Image.pas',
  Item.Coin in 'src\Items\Item.Coin.pas',
  TaskList in 'src\TaskList.pas';

const
  APP_CAPTION = 'Devil Hunter';
  APP_VERSION = '0.0.0.2';
  APP_STAGE = 'Pre-alpha';
  LIB_PATH = 'Lib\';

procedure Init( pParametr: Pointer ); stdcall;
begin
  SubSystems.Init;
  Resources.Load;

  SubSystems.Render.SetClearColor(Color4($0));
  SubSystems.Input.Configure( ICF_HIDE_CURSOR  );

  Game.Init;
  Game.Update( 1 );
end;

procedure Draw( pParametr: Pointer ); stdcall;
begin
  Render2D.Begin2D;

    Game.Render;

  Render2D.End2D;
end;

procedure Process( pParametr: Pointer ); stdcall;
begin
  Game.Update( 1 );
end;

procedure Free( pParametr: Pointer ); stdcall;
begin
  Resources.Free;

  SubSystems.Free;
end;

begin
  Settings.Load;

  if ( GetEngine( LIB_PATH + 'DGLE2.dll', EngineCore )) then
  begin
    if ( SUCCEEDED( EngineCore.InitializeEngine( 0, APP_CAPTION+' v.'+APP_VERSION+' '+APP_STAGE,
      EngWindow( Window.Width, Window.Height, Window.FullScreen,
                 Window.VSync, Window.MSAA, EWF_ALLOW_SIZEING ))))
    then
    begin
      EngineCore.ConsoleVisible( False );
      EngineCore.AddProcedure( EPT_INIT, @Init );
      EngineCore.AddProcedure( EPT_FREE, @Free );
      EngineCore.AddProcedure( EPT_PROCESS, @Process );
      EngineCore.AddProcedure( EPT_RENDER, @Draw );

      Randomize;
      EngineCore.StartEngine();
    end;
    FreeEngine();
  end
  else
    MessageBox( 0, 'Не удалось загрузить ' + LIB_PATH + 'DGLE2.dll',
      APP_CAPTION, MB_OK or MB_ICONERROR or MB_SETFOREGROUND );

end.
