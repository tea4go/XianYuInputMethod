 import { BottomTool, InputTool } from '../InputMethodExtensionAbility/pages/InputIndex';
 import { MainInputPanel } from '../InputMethodExtensionAbility/view/MainInputPanl';

 @Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {

    Column(){
      Row(){

      }.width('100%').height('50%').backgroundColor(Color.Gray)
      Row(){
        Column({ space: 5 }) {
          InputTool()
          MainInputPanel()
          BottomTool()
        }.width('100%').height('100%')
      }.width('100%').height('50%')
    }

    .height('100%')
    .width('100%')
  }
}