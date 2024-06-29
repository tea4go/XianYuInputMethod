import { spellToWord } from '../../cncharInput/cnchar/util/SpellToWordUtil';
import { WordDataSource } from '../dao/DataSouce';
import { KeyButtonData } from '../data/KeyButtonDataManager';
import keyboardController from '../model/KeyboardController';
import {  MainInputPanel } from '../view/MainInputPanl';
import { SmartSuggestionBar } from '../view/SmartSuggestionBar';


@Component
export struct BottomTool {
  build() {
    Row() {
      Button(){
        Image($r('app.media.keyboard')).width(40).height(40)
          .padding(5)
      }.backgroundColor(Color.Transparent)
      .width(40).height(40)

      Blank()
      Button(){
        Image($r('app.media.paste'))
          .padding(8)
      }.backgroundColor(Color.Transparent)
        .width(40).height(40)
    }.width('100%').height(40)
    .backgroundColor(Color.Transparent)
    .padding({left:16, right: 16, top: 2})
  }
}




@Component
@Entry
struct InputIndex {
  // 记录输入的键值
  @Provide inputContent:Array<KeyButtonData> = []
  // 是否为数字键盘格式
  @Provide numberMode:boolean = false;
  @Provide words: WordDataSource = new WordDataSource();

  build() {
    Stack() {

      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.End
      }) {
        Flex({
          direction: FlexDirection.Column,
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Column({ space: 5 }) {
            SmartSuggestionBar()
            MainInputPanel()
            BottomTool()
          }.width('100%').height('100%')

        }
        .align(Alignment.End)
        .width("100%")
        .height("100%")
      }
      .height("100%").align(Alignment.End).backgroundColor("#eff0f4")


    }
    .position({ x: 0, y: 0 }).zIndex(99999)
  }
}

