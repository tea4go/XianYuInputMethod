import { KeyButtonData } from '../InputMethodExtensionAbility/data/KeyButtonDataManager';
import { BottomTool, InputTool, TopTextTip } from '../InputMethodExtensionAbility/pages/InputIndex';
 import {  MainInputPanel } from '../InputMethodExtensionAbility/view/MainInputPanl';
import { router } from '@kit.ArkUI';
import { EnglishMainInputPanel } from '../InputMethodExtensionAbility/view/EnglishMainInputPanl';
import { NumberMainInputPanel } from '../InputMethodExtensionAbility/view/NumberMainInputPanl';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
   // 记录输入的键值
   @Provide inputContent:Array<KeyButtonData> = []
  // 是否为数字键盘格式
   @Provide numberMode:boolean = false;
   // 英文输入法模式
   @State englishMode:boolean = true

  build() {

    Column(){
      Row(){
        Column(){
          TextInput()
          Button("切换至中英文输入法界面")
            .onClick(()=>{
              this.englishMode = !this.englishMode;
            })
        }.width('100%')

      }.width('100%').height('50%').backgroundColor(Color.White)
      Row(){
        Stack(){
          Column({ space: 5 }) {
            TopTextTip()
          }.width('100%').height('100%')
          if(this.englishMode){
            Column({ space: 5 }) {
              TopTextTip()
              InputTool()
              if(this.numberMode){
                NumberMainInputPanel()
              }else{
                EnglishMainInputPanel()
              }
              BottomTool()
            }.width('100%').height('100%')
          }else{
            Column({ space: 5 }) {
              InputTool()
              MainInputPanel()
              BottomTool()
            }.width('100%').height('100%')
          }
        }

      }.width('100%').height('50%')
    }

    .height('100%')
    .width('100%')
  }
}
