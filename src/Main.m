
#import <AppKit/AppKit.h>

#import <Foundation/Foundation.h>

void inline_c_Main_0_6773341b15708dab7eba9f03235f03eaec94425f(NSString * txt_inline_c_0) {
 NSLog(@"%@", txt_inline_c_0); 
}


NSSpellChecker * inline_c_Main_1_e61a4100d8e8addd4f302e347d2fb4cf64b78a87() {
return ( [NSSpellChecker sharedSpellChecker] );
}


NSString * inline_c_Main_2_c58f5123c2249ca772623416f41fa0a95213010e(NSSpellChecker * sc_inline_c_0) {
return ( [(sc_inline_c_0) language] );
}


NSArray * inline_c_Main_3_41faee7b17db4e9bf70c1049af63e0472aef6c73(NSSpellChecker * sc_inline_c_0) {
return ( [(sc_inline_c_0) availableLanguages] );
}


NSArray * inline_c_Main_4_ca371e72cebc9afa08126dc128fad44594f10fb7(NSDictionary * dic_inline_c_0) {
return ( [(dic_inline_c_0) valueForKey: NSGrammarCorrections] );
}


NSString * inline_c_Main_5_46ded4bf175cb4efab6588915a42dc0987617814(NSDictionary * dic_inline_c_0) {
return ([(dic_inline_c_0) valueForKey: NSGrammarUserDescription]);
}


NSUInteger inline_c_Main_6_6d73e187d3e04016ddcf08c93aa15bc1be2e201b(NSDictionary * dic_inline_c_0) {
return ( [[(dic_inline_c_0) valueForKey: NSGrammarRange] rangeValue].location );
}


NSUInteger inline_c_Main_7_850f331ce997803d0491b599f8113a0d51fae29a(NSDictionary * dic_inline_c_0) {
return ( [[(dic_inline_c_0) valueForKey: NSGrammarRange] rangeValue].length );
}


void inline_c_Main_8_c7c3da7736cbf9df9b38d447099be36249b2a436(NSRange * nsarr_inline_c_0, NSString * txt_inline_c_1, NSInteger startingAt_inline_c_2, NSString * targLanguage_inline_c_3, BOOL doesWrap_inline_c_4, NSArray ** arrPtr_inline_c_5) {
 *nsarr_inline_c_0 = [[NSSpellChecker sharedSpellChecker]
                                   checkGrammarOfString: txt_inline_c_1
                                             startingAt: startingAt_inline_c_2
                                               language: targLanguage_inline_c_3
                                                   wrap: doesWrap_inline_c_4
                                 inSpellDocumentWithTag: 0
                                                details: arrPtr_inline_c_5
                           ];  
}


int inline_c_Main_9_83baabe29d15507cd4079e7873bc2025b4a23a56(NSArray * arr_inline_c_0) {
return ( arr_inline_c_0.count );
}


NSDictionary * inline_c_Main_10_ae5e4be238a2e10e4223894214578da14050ebab(NSArray * arr_inline_c_0, int i_inline_c_1) {
return ( [(arr_inline_c_0) objectAtIndex: i_inline_c_1 ] );
}


NSArray * inline_c_Main_11_72f53d620ddbabd55edf6324916db8bc93762886(NSDictionary * dic_inline_c_0) {
return ( [(dic_inline_c_0) allKeys] );
}


NSString * inline_c_Main_12_a56f03285d4df85d67ecc42c80e4059763679e9c(NSDictionary * dic_inline_c_0, NSString * k_inline_c_1) {
return ( [[(dic_inline_c_0) objectForKey: k_inline_c_1 ] description] );
}


NSMutableDictionary * inline_c_Main_13_1c807a2bcffae9e9d09f93a4d24924408d33ce9f(int size_inline_c_0) {
return ([NSMutableDictionary dictionaryWithCapacity: size_inline_c_0] );
}


void inline_c_Main_14_a3a0fcca8d76105620486ce6071dd06949960877(NSMutableDictionary * dic_inline_c_0, NSString * p_inline_c_1, NSString * k_inline_c_2) {
 [(dic_inline_c_0) setObject: p_inline_c_1 forKey: k_inline_c_2] ;
}

