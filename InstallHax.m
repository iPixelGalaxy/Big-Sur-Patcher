/*
by ASentientBot, edited by parrotgeek1

clang -dynamiclib -fmodules InstallHax.m -o Hax.dylib
codesign -f -s - Hax.dylib

csrutil disable
nvram boot-args='-no_compat_check amfi_get_out_of_my_way=1'

launchctl setenv DYLD_INSERT_LIBRARIES $PWD/Hax.dylib

*/

@import Foundation;
@import ObjectiveC.runtime;

void swizzle(Class realClass,Class fakeClass,SEL realSelector,SEL fakeSelector,BOOL instance)
{
	Method realMethod;
	Method fakeMethod;
	if(instance)
	{
		realMethod=class_getInstanceMethod(realClass,realSelector);
		fakeMethod=class_getInstanceMethod(fakeClass,fakeSelector);
	}
	else
	{
		realMethod=class_getClassMethod(realClass,realSelector);
		fakeMethod=class_getClassMethod(fakeClass,fakeSelector);
	}
	
	if(!realMethod||!fakeMethod)
	{
		return;
	}
	
	method_exchangeImplementations(realMethod,fakeMethod);
	
	NSLog(@"swizzle complete");
}

@interface FakeBIBuildInformation:NSObject
@end
@implementation FakeBIBuildInformation
-(BOOL)fakeIsUpdateInstallable:(id)something
{	
	return true;
}
@end

@interface Inject:NSObject
@end
@implementation Inject
+(void)load
{	
	swizzle(NSClassFromString(@"BIBuildInformation"),FakeBIBuildInformation.class,@selector(isUpdateInstallable:),@selector(fakeIsUpdateInstallable:),true);
}
@end