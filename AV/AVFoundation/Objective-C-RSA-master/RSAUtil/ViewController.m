//
//  ViewController.m
//  RSAUtil
//
//  Created by ideawu on 7/14/15.
//  Copyright (c) 2015 ideawu. All rights reserved.
//

#import "ViewController.h"
#import "BSCRSA.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];


	NSString *pubkey = @"-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApx8C4ZJX+xpRGw9KOME5xAc3abptkJ9J2TIKNpW+BAT7O92AK+03+z8IN68qW9rHY+s6zdjisHXKzRD3cA4FmEsNQ1YLjs+HEryiaBQyJfgde6ejV//GkJ8bgUFb2haF+/KdNgBbM9msVCx+yFqXOHQBpogD/7yamzpeLLJ10rwialHifC5kVNw71XDtAGP9VPUxTshq+6DdeZw0jmgFE3hFZqjq9Wov36yrCwHjIRbT+JBEMn/7bksjvkQcugc6vTVJzdZlfUM/2ckt89gLtAZqz5idrmz8Xf7YbAjE9tLnV+7ZGoI8z6vxxF9X4LBP3rDmjmkEjck8yO9FYsapaQIDAQAB\n-----END PUBLIC KEY-----";
	
    
    NSString *privkey = @"-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCnHwLhklf7GlEbD0o4wTnEBzdpum2Qn0nZMgo2lb4EBPs73YAr7Tf7Pwg3rypb2sdj6zrN2OKwdcrNEPdwDgWYSw1DVguOz4cSvKJoFDIl+B17p6NX/8aQnxuBQVvaFoX78p02AFsz2axULH7IWpc4dAGmiAP/vJqbOl4ssnXSvCJqUeJ8LmRU3DvVcO0AY/1U9TFOyGr7oN15nDSOaAUTeEVmqOr1ai/frKsLAeMhFtP4kEQyf/tuSyO+RBy6Bzq9NUnN1mV9Qz/ZyS3z2Au0BmrPmJ2ubPxd/thsCMT20udX7tkagjzPq/HEX1fgsE/esOaOaQSNyTzI70VixqlpAgMBAAECggEAXV3f+DIQYUM0qM+EAe1B3pjBhpoW+ENluKhSOGi0Pf6idbGsF95x9jYi2ylLmwHBf7s9oR9YlolYgfTGqJ3M1manxETgNCsRJZCpk0glND1IC3t+sH0/bDDX5wCi1lbbCAVle3P7gB5OPsCVHE4wSePVwDohMdEm9y5GyuXxGYgG7K4SaQqsoP+NZB02Q7RBAFz0eiMonp6atomepWei1l9a1U/oyoYi2641g+w5c+1RyOV5koy16fe4tfhR3VOpPHFFfJ3kOs+m4jb14XjEXJYpiJMr8u7+XbhcLZ98t9MGbpKe8ghZZ50H15d68PfgVxxg9Nl8i0f4XCvFnPpbmQKBgQDTnRMUdmYd9e8ISkqsYa1D4V4NNTe9HvnP8zhGqLCicJwGkG6yfzq3Uf7+dpJvUn9reSVLIaqoPh2ZKysjqg3X5N088EONUGldAxb6hQMRATgs/Xa+eqa3Z4bxo549uXM/Je27QddD+sUEccVKQk5AzqiBrvVt+6FI3oRO7TuRcwKBgQDKLNhWosGJeyFmXNvtIXjQRMXwS+i6tup5GAAiF2YGvC76jLW1x98x1sq1wJHe5K4pZtNfQjU1RbOOemxNlR3S4ceHa23IGl2PF1DjNI6oBGk1UEZIJjtN1mJ3FL3a2m04LK7lSqdzuIo/Kj/eUpXmvZuSfj9gj3e0WD671YqyswKBgEA0LBHNSnZUo810HOvoRtWNjyeaueqbd1fsh2qIy+69E9m6AJwPlhUAv8kc2JkGArrs6q+86zZYgkpymogblE+olKdkjlpVx2H9Cf/AU4nZQN4FmP154RNMSdkOt3gqyBikvVhPRazObPBIRH+fVna7PMz79GMGMY0WVjZMLAKZAoGAMEqB6j+6BsK4eaDYj02dc/HZbcpT7rVeUEphTcNVBWrRtdsCVEdHkroBdWRn81ugFhePiYNg/jaF6xRm5ikmFIcFh90rPc6+Zj1lfr/BC3TyRF/GSdmH9NGud08nAi2GRRK3O+GXGdcMfoXy94G2eIT1sgohzUi3iQZDBc698G0CgYAXisjbH+zOe2h+Y5S3wA/ga2blo7upP5D/mST4H+hZL1ZhaNCmvsnDjjQ7l3i/pwF4rNmG8hZ4PhSOrG3LVCiKzKH1MAssRuBj+ku+MnwcKHrMFrn5Dj86MNzvJbB6pqq/FxNLtciW8cceMm8f3jDje2BoMX510Br0aqfu1XSvNQ==\n-----END PRIVATE KEY-----";

//	NSString *originString = @"hello world!";
//	for(int i=0; i<4; i++){
//		originString = [originString stringByAppendingFormat:@" %@", originString];
//	}
	NSString *encWithPubKey;
	NSString *decWithPrivKey;
	NSString *encWithPrivKey;
	NSString *decWithPublicKey;
	
//	NSLog(@"Original string(%d): %@\n", (int)originString.length, originString);
	
	// Demo: encrypt with public key
//	encWithPubKey = [BSCRSA encryptString:originString publicKey:pubkey];
//	NSLog(@"Enctypted with public key: %@\n", encWithPubKey);
    
    
    
    encWithPubKey = @"XoivD/92BfEvlKZjpsqhKse/qSX2fJbdyM31PNPzKxd0aIjMUuSa27PMpzSPtvHXqP1EPZ3GT2iE0ig95ZSY15sMfG5e3WVvluTJ4SrJq/lRvmUsOaR6qMmdvpaqmBfhZ0/TUnpUedJe8gU3R2HB937YlNKPcnkxNmqQpQPZ5c2dYEIFHAHY8yaB2ZXMF+cTHybYVasSMDkutp+VGt3qfsLc64luwRA0MQ1Rwr0UoxtS6POZrJaRA/XITqC3nMuStvrszAAoBINnyTtZkAvDISYagB22Egjydq3zEn1QQC0xxrycoA7ZEo4jFCCVdmxmXnDvslFhd0fBRLvWWhwswg==";
    
	// Demo: decrypt with private key
	decWithPrivKey = [BSCRSA decryptString:encWithPubKey privateKey:privkey];
	NSLog(@"Decrypted with private key: %@\n", decWithPrivKey);
    
    
    
    
    
    
	
//	// by PHP
//	encWithPubKey = @"CKiZsP8wfKlELNfWNC2G4iLv0RtwmGeHgzHec6aor4HnuOMcYVkxRovNj2r0Iu3ybPxKwiH2EswgBWsi65FOzQJa01uDVcJImU5vLrx1ihJ/PADUVxAMFjVzA3+Clbr2fwyJXW6dbbbymupYpkxRSfF5Gq9KyT+tsAhiSNfU6akgNGh4DENoA2AoKoWhpMEawyIubBSsTdFXtsHK0Ze0Cyde7oI2oh8ePOVHRuce6xYELYzmZY5yhSUoEb4+/44fbVouOCTl66ppUgnR5KjmIvBVEJLBq0SgoZfrGiA3cB08q4hb5EJRW72yPPQNqJxcQTPs8SxXa9js8ZryeSxyrw==";
//	decWithPrivKey = [BSCRSA decryptString:encWithPubKey privateKey:privkey];
//	NSLog(@"(PHP enc)Decrypted with private key: %@", decWithPrivKey);
//	
//	// Demo: encrypt with private key
//	// TODO: encryption with private key currently NOT WORKING YET!
//	//encWithPrivKey = [RSA encryptString:originString privateKey:privkey];
//	//NSLog(@"Enctypted with private key: %@", encWithPrivKey);
//
//	// Demo: decrypt with public key
//	encWithPrivKey = @"aQkSJwaYppc2dOGEOtgPnzLYX1+1apwqJga2Z0k0cVCo7vCqOY58PyVuhp49Z+jHyIEmIyRLsU9WOWYNtPLg8XDnt1WLSst5VNyDlJJehbvm7gbXewxrPrG+ukZgo11GYJyU42DqNr59D3pQak7P2Ho6zFvN0XJ+lnVXJ1NTmgQFQYeFksTZFmJmQ5peHxpJy5XBvqjfYOEdlkeiiPKTnTQaQWKJfC9CRtWfTTYM2VKMBSTB0eNWto5XAu5BvgEgTXzndHGzsWW7pOHLqxVagr0xhNPPCB2DRE5PClE2FD9qNv0JcSMnUJ8bLvk6Yeh7mMDObJ4kBif5G9VnHjTqTg==";
//	decWithPublicKey = [BSCRSA decryptString:encWithPrivKey publicKey:pubkey];
//	NSLog(@"(PHP enc)Decrypted with public key: %@", decWithPublicKey);
}

@end
