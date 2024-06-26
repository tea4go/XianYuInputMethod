 import { BottomTool, InputTool, TopTextTip } from '../InputMethodExtensionAbility/pages/InputIndex';
 import { InputButtonData, MainInputPanel } from '../InputMethodExtensionAbility/view/MainInputPanl';

 @Entry
@Component
struct Index {
  @State message: string = 'Hello World';
   // 记录输入的键值
   @Provide inputContent:Array<InputButtonData> = []

  build() {

    Column(){
      Row(){
        TextInput()
      }.width('100%').height('50%').backgroundColor(Color.White)
      Row(){
        Stack(){
          Column({ space: 5 }) {
            TopTextTip().offset({x:0, y:-30})

          }.width('100%').height('100%')
          Column({ space: 5 }) {

            InputTool()
            MainInputPanel()
            BottomTool()
          }.width('100%').height('100%')
        }

      }.width('100%').height('50%')
    }

    .height('100%')
    .width('100%')
  }
}
