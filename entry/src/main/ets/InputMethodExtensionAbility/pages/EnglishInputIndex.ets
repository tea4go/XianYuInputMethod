import { spellToWord } from '../../cncharInput/cnchar/util/SpellToWordUtil';
import { KeyButtonData } from '../data/KeyButtonDataManager';
import { EnglishMainInputPanel } from '../view/EnglishMainInputPanl';
import { NumberMainInputPanel } from '../view/NumberMainInputPanl';
import { BottomTool, InputTool, TopTextTip } from './InputIndex';


@Component
@Entry
struct EnglishInputIndex {
  // 记录输入的键值
  @State  inputContent:Array<KeyButtonData> = []
  // 是否为数字键盘格式
  @State numberMode:boolean = true;

  // @Provide  inputContent:Array<KeyButtonData> = []
  // // 是否为数字键盘格式
  // @Provide numberMode:boolean = true;

  aboutToAppear(): void {
    this.numberMode = false
  }

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
          Column({ space: 8 }) {
            TopTextTip()
            InputTool()
            EnglishMainInputPanel()
            BottomTool()
          }.width('100%').height('100%')
          .backgroundColor("#eff0f4")

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

