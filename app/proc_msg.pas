(*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Copyright (c) Alexey Torgashin
*)
unit proc_msg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  ATBinHex,
  ATSynEdit;

const
  cAppExeVersion = '1.96.0.1';
  cAppApiVersion = '1.0.321';

const
  cOptionSystemSuffix =
    {$ifdef windows} '' {$endif}
    {$ifdef linux} '__linux' {$endif}
    {$ifdef darwin} '__mac' {$endif}
    {$ifdef freebsd} '__freebsd' {$endif}
    {$ifdef netbsd} '__netbsd' {$endif}
    {$ifdef openbsd} '__openbsd' {$endif}
    {$ifdef dragonfly} '__dragonfly' {$endif}
    {$ifdef solaris} '__solaris' {$endif}
    {$ifdef haiku} '__haiku' {$endif}
    ;

const
  EOL = #10;
  msgPythonListError = 'Cannot create new list object'; //no need i18n
  msgCallbackBad = 'Bad API callback, report to plugin author: %s'; //no i18n
  msgCallbackDeprecated = 'Deprecated API callback, report to plugin author: %s'; //no i18n
  msgApiDeprecated = 'Deprecated API usage: %s'; //no i18n
  msgErrorInTheme = 'Warning for theme "%s": missed item "%s"';
  msgCmdPalettePrefixHelp = '#p – plugins'+EOL+'#l – lexers'+EOL+'#f – opened files'+EOL+'#r – recent files';
  msgRescannedAllPlugins = 'Rescanned all plugins';

  msgPluginIgnored = 'NOTE: plugin %s ignored, remove it';
  msgCannotFindLexers = 'NOTE: Cannot find lexers: %s';
  msgCannotFindData = 'NOTE: Cannot find data: %s';

  msgTitle = 'CudaText'; //no i18n
  msgModified: array[boolean] of string = ('', '*'); //no i18n
  msgLiteLexerSuffix = ' ^'; //no i18n

  msgDialogTitleOpen: string = 'Open file';
  msgDialogTitleSaveAs: string = 'Save file as';
  msgDialogTitleSelFolder: string = 'Select folder';

  msgTooltipClearFilter: string = 'Clear filter';
  msgTooltipCloseTab: string = 'Close tab';
  msgTooltipAddTab: string = 'Add tab';
  msgTooltipArrowLeft: string = 'Scroll tabs left';
  msgTooltipArrowRight: string = 'Scroll tabs right';
  msgTooltipArrowMenu: string = 'Show tabs menu';

  msgUntitledTab: string = 'Untitled';
  msgAllFiles: string = 'All files';
  msgNoLexer: string = '(none)';
  msgThemeDefault: string = '(default)';
  msgThemeName: string = 'Theme name:';
  msgGotoDialogTooltip: string = '(10, 10:10, 10%%, d100, xFFF, %s)';
  msgGotoDialogInfoExt: string = 'with "+": select';

  msgMenuTranslations: string = 'Translations';
  msgMenuThemesUI: string = 'UI themes';
  msgMenuThemesSyntax: string = 'Syntax themes';
  msgMenuLexersForFile: string = 'Lexer for "%s"';

  msgPanelMenu_Init = 'Menu';
  msgPanelTree_Init = 'Code tree';
  msgPanelProject_Init = 'Project';
  msgPanelTabs_Init = 'Tabs';
  msgPanelSnippet_Init = 'Snippet Panel';

  msgPanelConsole_Init = 'Console';
  msgPanelOutput_Init = 'Output';
  msgPanelValidate_Init = 'Validate';
  msgPanelSearch_Init = 'Search';

  msgPanelMenu: string = msgPanelMenu_Init;
  msgPanelTree: string = msgPanelTree_Init;
  msgPanelProject: string = msgPanelProject_Init;
  msgPanelTabs: string = msgPanelTabs_Init;
  msgPanelSnippet: string = msgPanelSnippet_Init;

  msgPanelConsole: string = msgPanelConsole_Init;
  msgPanelOutput: string = msgPanelOutput_Init;
  msgPanelValidate: string = msgPanelValidate_Init;
  msgPanelSearch: string = msgPanelSearch_Init;

  msgFinderHintRegex: string = 'regex';
  msgFinderHintCase: string = 'case';
  msgFinderHintWords: string = 'words';
  msgFinderHintBack: string = 'back';
  msgFinderHintWrapped: string = 'wrapped';
  msgFinderHintInSel: string = 'in-sel';
  msgFinderHintFromCaret: string = 'from-caret';

  msgButtonOk: string = 'OK';
  msgButtonCancel: string = 'Cancel';
  msgButtonApply: string = 'Apply';
  msgButtonClose: string = 'Close';
  msgButtonYes: string = 'Yes';
  msgButtonNo: string = 'No';
  msgButtonYesAll: string = 'Yes to all';
  msgButtonNoAll: string = 'No to all';
  msgButtonAbort: string = 'Abort';
  msgButtonRetry: string = 'Retry';
  msgButtonIgnore: string = 'Ignore';

  msgFileNew: string = 'New file';
  msgFileOpen: string = 'Open file...';
  msgFileSave: string = 'Save file';
  msgFileClearList: string = 'Clear list';
  msgCopySub: string = 'Copy to clipboard';
  msgCopyFilenameName: string = 'Copy filename only';
  msgCopyFilenameDir: string = 'Copy filepath only';
  msgCopyFilenameFull: string = 'Copy full filepath';

  msgEncReloadAs: string = 'Reload as';
  msgEncConvertTo: string = 'Convert to';
  msgEncEuropean: string = 'European';
  msgEncAsian: string = 'Asian';
  msgEncMisc: string = 'Misc';

  msgEndWin: string = 'CRLF';
  msgEndUnix: string = 'LF';
  msgEndMac: string = 'CR';

  msgTabsizeUseSpaces: string = 'Use spaces';
  msgTabsizeConvTabs: string = 'Convert indentation to spaces';
  msgTabsizeConvSpaces: string = 'Convert indentation to tabs';

  msgCannotInitPython1: string = 'NOTE: No Python 3 engine found. Python plugins don''t work now. To fix this:';
  {$ifdef darwin}
  msgCannotInitPython2: string = 'install Python 3.x from www.python.org, it should be found by CudaText then.';
  {$else}
    {$ifdef windows}
    msgCannotInitPython2: string = 'place near cudatext.exe: python3x.dll, python3x.zip, python3xdlls\*.pyd, MS VS Runtime.';
    {$else}
    msgCannotInitPython2: string = 'write option "pylib'+cOptionSystemSuffix+
                                   '" to user.json. See info in default config: Options / Settings-default.';
    {$endif}
  {$endif}

  msgCannotOpenFile: string = 'Cannot open file:';
  msgCannotFindFile: string = 'Cannot find file:';
  msgCannotFindLexerInLibrary: string = 'Cannot find lexer in library:';
  msgCannotFindLexerFile: string = 'Cannot find lexer file:';
  msgCannotFindSublexerInLibrary: string = 'Cannot find linked sublexer:';
  msgCannotFindWithoutCaret: string = 'Cannot find/replace without caret';
  msgCannotCreateDir: string = 'Cannot create dir:';
  msgCannotSaveFile: string = 'Cannot save file:';
  msgCannotSaveFileWithEnc: string = 'Could not save file because encoding "%s" cannot handle Unicode text. Program has saved file in UTF-8 encoding.';
  msgCannotSaveUserConf: string = 'Cannot save user config (read only?)';
  msgCannotReadConf: string = 'Cannot read/parse config:';
  msgCannotReloadUntitledTab: string = 'Cannot reopen untitled tab';
  msgCannotFindInMultiSel: string = 'Cannot find in multi-selections, yet';
  msgCannotFindMatch: string = 'Cannot find';
  msgCannotFindInstallInfInZip: string = 'Cannot find install.inf in zip file';
  msgCannotFindBookmarks: string = 'Cannot find bookmarks in text';
  msgCannotHandleZip: string = 'Cannot handle zip file:';
  msgCannotSetHotkey: string = 'Cannot set hotkey for this item';
  msgCannotInstallAddonApi: string = 'Cannot install add-on "%s", it needs newer application version (API %s)';
  msgCannotInstallOnOS: string = 'Cannot install add-on "%s", it requires another OS (%s)';
  msgCannotInstallReqPlugin: string = 'Cannot install "%s", it requires missing plugin(s): %s';
  msgCannotInstallReqLexer: string = 'Cannot install "%s", it requires missing lexer(s): %s';
  msgCannotAutocompleteMultiCarets: string = 'Cannot auto-complete with multi-carets';

  msgStatusbarTextTab: string = 'Tab';
  msgStatusbarTextSpaces: string = 'Spaces';

  msgStatusbarTextLine: string = 'Ln';
  msgStatusbarTextCol: string = 'Col';
  msgStatusbarTextSel: string = 'sel';
  msgStatusbarTextLinesSel: string = 'lines sel';
  msgStatusbarTextCarets: string = 'carets';

  msgStatusbarWrapStates: array[0..Ord(High(TATSynWrapMode))] of string =
    ('no wrap', 'wrap', 'margin', 'wnd/mrg');

  msgStatusbarHintCaret: string = 'Caret position, selection';
  msgStatusbarHintEnc: string = 'File encoding';
  msgStatusbarHintLexer: string = 'Lexer (language)';
  msgStatusbarHintEnds: string = 'End-of-line chars';
  msgStatusbarHintSelMode: string = 'Mouse selection mode (normal/column)';
  msgStatusbarHintTabSize: string = 'Tabulation width, by space-chars';
  msgStatusbarHintInsOvr: string = 'Insert/Overwrite mode';
  msgStatusbarHintWrap: string = 'Word wrap (off, by window, by fixed margin)';

  msgStatusI18nEnglishAfterRestart: string = 'English translation will be applied after program restart';
  msgStatusI18nPluginsMenuAfterRestart: string = 'Translations of Plugins menu and plugin''s dialogs will be applied after program restart';

  msgStatusPluginHotkeyBusy: string = 'Warning: hotkey [%s] is busy, it was not set';
  msgStatusSyntaxThemesOff: string = 'Syntax themes are turned off by option "ui_lexer_themes": false. So the following dialog will have no effect. To customize styles, use "Lexer properties" dialog.';
  msgStatusIncorrectInstallInfInZip: string = 'Incorrect install.inf in zip';
  msgStatusUnsupportedAddonType: string = 'Unsupported addon type:';
  msgStatusPackageContains: string = 'This package contains:';
  msgStatusPackageName: string = 'name:';
  msgStatusPackageType: string = 'type:';
  msgStatusPackageDesc: string = 'description:';
  msgStatusPackageCommand: string = 'command:';
  msgStatusPackageEvents: string = 'events:';
  msgStatusPackageLexer: string = 'lexer:';
  msgStatusPackageLexerSettings: string = 'lexer settings:';
  msgStatusPackageAutoCompletion: string = 'static auto-completion:';
  msgStatusPackageData: string = 'data:';
  msgStatusPackagePackage: string = 'package:';
  msgStatusPackageMissedLexerMap: string = 'lexer misses themes support (.cuda-lexmap file)';
  msgStatusInstalledNeedRestart: string = 'Package will take effect after program restart';
  msgStatusCommandOnlyForLexers: string = 'Command is only for lexers:';
  msgStatusOpenedBrowser: string = 'Opened browser';
  msgStatusCopiedLink: string = 'Copied link';
  msgStatusAddonInstalled: string = 'Package installed';
  msgStatusAddonsInstalled: string = 'Installed several packages (up to %d)';
  msgStatusOpened: string = 'Opened:';
  msgStatusReopened: string = 'Reopened:';
  msgStatusBadRegex: string = 'Incorrect regex passed:';
  msgStatusFoundNextMatch: string = 'Found next match';
  msgStatusTryingAutocomplete: string = 'Trying auto-complete for:';
  msgStatusHelpOnShowCommands: string = 'Commands: F9 to configure keys; "@key" to find hotkey';
  msgStatusNoLineCmtDefined: string = 'No line comment defined for lexer';
  msgStatusReplaceCount: string = 'Replaces made: %d';
  msgStatusFindCount: string = 'Count of "%s": %d';
  msgStatusFoundFragments: string = 'Found %d different fragment(s)';
  msgStatusReadingOps: string = 'Reading options';
  msgStatusSavedFile: string = 'Saved:';
  msgStatusReadonly: string = '[Read Only]';
  msgStatusMacroRec: string = '[Macro Rec]';
  msgStatusPictureNxN: string = 'Image %dx%d';
  msgStatusHexViewer: string = 'Hex';
  msgStatusCancelled: string = 'Cancelled';
  msgStatusBadLineNum: string = 'Incorrect number entered';
  msgStatusEndsChanged: string = 'Line ends changed';
  msgStatusEncChanged: string = 'Encoding changed';
  msgStatusGotoFileLineCol: string = 'File "%s", Line %d Col %d';
  msgStatusHelpOnKeysConfig: string = 'To customize hotkeys, call "Help - Command palette", focus needed command, and press F9, you''ll see additional dialog';
  msgStatusClickingLogLine: string = 'Clicking log line';
  msgStatusNoGotoDefinitionPlugins: string = 'No goto-definition plugins installed for this lexer';
  msgStatusFilenameAlreadyOpened: string = 'File name is already opened in another tab:';
  msgStatusNeedToCloseTabSavedOrDup: string = 'You need to close tab: saved-as or duplicate.';
  msgStatusHotkeyBusy: string = 'Hotkey is busy: %s';
  msgStatusChangedLinesCount: string = 'Changed %d lines';

  msgConfirmHotkeyBusy: string = 'Hotkey is already occupied by command:'#13'%s'#13#13'Overwrite it?';
  msgConfirmSyntaxThemeSameName: string = 'Syntax theme exists, with the same name as UI theme. Do you want to apply it too?';
  msgConfirmInstallIt: string = 'Do you want to install it?';
  msgConfirmFileChangedOutside: string = 'File was changed outside:';
  msgConfirmReloadIt: string = 'Reopen it?';
  msgConfirmReloadYes: string = 'Reload';
  msgConfirmReloadNoMore: string = 'No more notifications';
  msgConfirmReloadItHotkeysSess: string = '(Yes: reopen. No: open text from previous session.)';
  msgConfirmOpenCreatedDoc: string = 'Open created document?';
  msgConfirmSaveColorsToFile: string = 'Save theme to file?';
  msgConfirmSaveModifiedTab: string = 'Tab is modified:'#13'%s'#13#13'Save it first?';
  msgConfirmReopenModifiedTab: string = 'Tab is modified:'#13'%s'#13#13'Reopen it?';
  msgConfirmReloadFileWithEnc: string = 'Encoding is changed in memory.'#13'Do you also want to reopen file?';
  msgConfirmCreateNewFile: string = 'File not found:'#13'"%s"'#13#13'Create it?';
  msgConfirmCreateUserConf: string = 'User config not found. Create it?';
  msgConfirmCloseDelFile: string = 'Close tab and delete its file?';
  msgConfirmDeleteLexer: string = 'Delete lexer "%s"?';
  msgConfirmRemoveStylesFromBackup: string = 'Remove checked styles from backup file?';
  msgConfirmReplaceGlobal: string = 'This will perform mass replace in all opened documents. This will also reset all selections. Continue?';

  msgAboutCredits =
      'Lazarus IDE'+EOL+
      '  http://www.lazarus-ide.org'+EOL+
      ''+EOL+
      'ATSynEdit, ATTabs, ATFlatControls, Python wrapper'+EOL+
      '  Alexey Torgashin'+EOL+
      '  https://github.com/Alexey-T/'+EOL+
      ''+EOL+
      'EControl syntax parser'+EOL+
      '  Delphi version by Michael Zakharov'+EOL+
      '  http://www.econtrol.ru'+EOL+
      '  Lazarus port by Alexey Torgashin'+EOL+
      '  https://github.com/Alexey-T/'+EOL+
      ''+EOL+
      'Helper Python code:'+EOL+
      '  Andrey Kvichanskiy'+EOL+
      '  https://github.com/kvichans/'+EOL+
      ''+EOL+
      'Icons:'+EOL+
      ''+EOL+
      'Main icon:'+EOL+
      '  FTurtle'+EOL+
      'Theme for LibreOffice:'+EOL+
      '  https://github.com/libodesign/icons'+EOL+
      '  License: Creative Commons BY-SA 3.0, http://creativecommons.org/licenses/by-sa/3.0/'+EOL+
      'Octicons:'+EOL+
      '  https://octicons.github.com/'+EOL+
      '  License: MIT License'+EOL+
      'Visual Studio Code icons:'+EOL+
      '  https://github.com/vscode-icons/vscode-icons'+EOL+
      '  License: MIT License'+EOL+
      'Hourglass/floppy icons:'+EOL+
      '  https://www.iconfinder.com/snipicons'+EOL+
      '  License: Creative Commons BY-NC 3.0 Unported, http://creativecommons.org/licenses/by-nc/3.0/'+EOL+
      '';

  msgCommandLineHelp =
      'Usage:'+EOL+
      '  cudatext [ key ... ] filename ...'+EOL+
      ''+EOL+
      'Supported keys:'+EOL+
      '  -h, --help      - Show this help and exit'+EOL+
      '  -v, --version   - Show application version and exit'+EOL+
      '  -z=[text|binary|hex|unicode] - Open arguments in internal viewer'+EOL+
      '  -r              - Open arguments in read-only mode'+EOL+
      '  -e=value        - Open arguments in given encoding'+EOL+
      '  -el             - Show supported encoding names and exit'+EOL+
      '  -n              - Ignore option "ui_one_instance", open new app window'+EOL+
      '  -nh             - Ignore saved file history'+EOL+
      '  -ns             - Ignore saved session'+EOL+
      '  -w=left,top,width,height - Set position/size of app window'+EOL+
      '  -i              - Open contents of stdin in new tab (Unix only)'+EOL+
      ''+EOL+
      'Filenames can be with ":line" or ":line:column" suffix to place caret.'+EOL+
      'Folder can be passed, will be opened in Project Manager plugin.'+EOL+
      'Projects (.cuda-proj) can be passed, will be opened in Project Manager.'+EOL+
      'Sessions (.cuda-session) can be passed, if Session Manager installed.'+EOL;

  msgFirstStartInfo =
      '---------------------------------------------------------------'+EOL+
      'This is the first CudaText start (file history.json not found).'+EOL+
      'You can easily install popular add-ons'+EOL+
      {$ifdef unix}
      '(if Python option "pylib'+cOptionSystemSuffix+'" is set up)'+EOL+
      {$endif}
      'using menu item "Plugins / Multi Installer".'+EOL+
      '---------------------------------------------------------------'+EOL;

const
  msgDefault: string = 'Default';
  msgTreeSorted: string = 'Sorted';

  msgViewer: string = 'Viewer';
  msgViewerModes: array[TATBinHexMode] of string = (
    'Text',
    'Binary',
    'Hex',
    'Unicode',
    'Unicode/Hex'
    );

  msgTextCaseMenu: string = 'Convert case';
  msgTextCaseUpper: string = 'Upper case';
  msgTextCaseLower: string = 'Lower case';
  msgTextCaseTitle: string = 'Title case';
  msgTextCaseInvert: string = 'Invert case';
  msgTextCaseSentence: string = 'Sentence case';

  msgCommentLineAdd: string = 'Line comment: add';
  msgCommentLineDel: string = 'Line comment: remove';
  msgCommentLineToggle: string = 'Line comment: toggle';
  msgCommentStreamToggle: string = 'Stream comment: toggle';

  msgSortAsc: string = 'Sort ascending';
  msgSortDesc: string = 'Sort descending';
  msgSortAscNocase: string = 'Sort ascending, ignore case';
  msgSortDescNocase: string = 'Sort descending, ignore case';
  msgSortDialog: string = 'Sort dialog...';
  msgSortReverse: string = 'Reverse lines';
  msgSortShuffle: string = 'Shuffle lines';
  msgSortRemoveDup: string = 'Remove duplicate lines';
  msgSortRemoveBlank: string = 'Remove blank lines';

  msgConsoleClear: string = 'Clear';
  msgConsoleToggleWrap: string = 'Toggle word wrap';
  msgConsoleNavigate: string = 'Navigate';

function msgUntitledNumberedCaption: string;
function msgTranslatedPanelCaption(const ACaption: string): string;


implementation

var
  FUntitledCount: integer = 0;

function msgUntitledNumberedCaption: string;
begin
  Inc(FUntitledCount);
  Result:= msgUntitledTab+IntToStr(FUntitledCount);
end;

function msgTranslatedPanelCaption(const ACaption: string): string;
begin
  case ACaption of
    msgPanelTree_Init:
      Result:= msgPanelTree;
    msgPanelProject_Init:
      Result:= msgPanelProject;
    msgPanelTabs_Init:
      Result:= msgPanelTabs;
    msgPanelSnippet_Init:
      Result:= msgPanelSnippet;
    msgPanelConsole_Init:
      Result:= msgPanelConsole;
    msgPanelOutput_Init:
      Result:= msgPanelOutput;
    msgPanelValidate_Init:
      Result:= msgPanelValidate;
    else
      Result:= ACaption;
  end;
end;

end.

