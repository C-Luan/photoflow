import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

var numberphoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy);
