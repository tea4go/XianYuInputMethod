import { PinyinDataSource } from '../dao/DataSouce';
import { KeyButtonData } from '../data/KeyButtonDataManager';
import {  MainInputPanel } from '../view/MainInputPanl';
import { PinyinDetailView } from '../view/PinyinDetailView';
import { SmartSuggestionBar, SuggestionWord } from '../view/SmartSuggestionBar';


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

  @Provide showPinYinListPage:boolean = false;
  // 已使用的
  @Provide useWords:Array<SuggestionWord> = []
  @Provide pinyinList: PinyinDataSource = new PinyinDataSource();

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
            if(this.showPinYinListPage){
              PinyinDetailView()
            }else{
              MainInputPanel()
            }

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

