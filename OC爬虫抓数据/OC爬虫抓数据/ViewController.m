//
//  ViewController.m
//  OC爬虫抓数据
//
//  Created by Wangguibin on 2017/5/19.
//  Copyright © 2017年 王贵彬. All rights reserved.
//

#import "ViewController.h"

/**  
 	爬数据 :  准确, 有顺序
 

 */

#define kBaseURL @"http://www.budejie.com"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

	[self spider];
}

- (void)spider{
		//1. url
		//2. 发送网络请求[ 一个个来,不要搞异步, 不然被发现会被封IP] 使用同步网络请求

		NSURL *url = [NSURL URLWithString:kBaseURL];
	NSURLRequest *request =[[NSURLRequest alloc] initWithURL:url];

	NSError *error;
	 NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
	NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//	NSLog(@"%@",html);
/**
		/// MARK- 做字符串分析,范围越集中越好
		/// MARK- 找到列表部分的文字  (.*?) 就是要的内容
		///在整个页面内容中--- <!-- gaga type: 1  None -->起始    </div>结尾
 */

	/**
	 NSRegularExpressionCaseInsensitive // 不区分大小写的
	 NSRegularExpressionAllowCommentsAndWhitespace// 忽略空格和# -
	 NSRegularExpressionIgnoreMetacharacters //整体化
	 NSRegularExpressionDotMatchesLineSeparators // 匹配任何字符，包括行分隔符
	 NSRegularExpressionAnchorsMatchLines// 允许^和$在匹配的开始和结束行
	 NSRegularExpressionUseUnixLineSeparators// (查找范围为整个的话无效)
	 NSRegularExpressionUseUnicodeWordBoundaries// (查找范围为整个的话无效)
	 */

	NSString *pattern = @"<!-- gaga type: 1  None -->(.*?)</div>";
	NSString *content = [self matchContentWithHtml: html pattern: pattern];
//	NSLog(@"%@",content);

		/// content 生成数组
	NSString *arrPattern = @"<a .*?=\"(.*?)\">(.*?)</a>";

	NSError* eror = NULL;
	NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern: arrPattern options:NSRegularExpressionCaseInsensitive |
								NSRegularExpressionDotMatchesLineSeparators error:&eror];
	NSArray* match  = [reg matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];

	if (match.count != 0)
	  {
    for (NSTextCheckingResult *matc in match)
	  {
		NSMutableDictionary *dict =[NSMutableDictionary dictionary];
		NSRange range = [matc range];
		NSString *subHtmlString = [content substringWithRange: range] ;
		NSString *title = [self matchContentWithHtml: subHtmlString  pattern:@"<a .*>(.*?)</a>"];
		NSString *url =[self matchContentWithHtml: subHtmlString pattern:@"<a .*\"(.*?)\">.*?</a>"];

		[dict setObject:title forKey:@"title"];
		[dict setObject:url forKey:@"url"];

			/// 一次性不要采集过于频繁 这样做容易封IP
		if ([title isEqualToString:@"全部"]) {

		}else if ([title isEqualToString:@"视频"]){

		}else if ([title isEqualToString:@"图片"]){

		}
		else if ([title isEqualToString:@"声音"]){

		}
		else if ([title isEqualToString:@"段子"]){
			[self parserDataWithDict: dict];

		}else if ([title isEqualToString:@"排行"]){

		}
		else if ([title isEqualToString:@"美女"]){
			
		  }

	   }
	}

}


- (NSString *)matchContentWithHtml:(NSString *)html pattern:(NSString *)pattern{
	NSRegularExpression *regx = [[NSRegularExpression alloc] initWithPattern: pattern options: NSRegularExpressionCaseInsensitive |
								 NSRegularExpressionDotMatchesLineSeparators  error:NULL];
		//匹配内容
	NSTextCheckingResult *result = [regx firstMatchInString:html options:0 range:NSMakeRange(0, html.length)];
	NSRange  range = [result rangeAtIndex:1];
	NSString *content = [html substringWithRange: range];
//	NSLog(@"%@",content);
	return content;
}


- (void)parserDataWithDict:(NSDictionary *)dict{
	NSString *title = dict[@"title"];
	NSString *url = [NSString stringWithFormat:@"%@%@",kBaseURL,dict[@"url"]];
	[self requestDataWithURL: url title: title];
}


- (void)requestDataWithURL:(NSString *)urlStr title:(NSString *)title{
	urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString: urlStr];
	NSURLRequest *request =[[NSURLRequest alloc] initWithURL:url];
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
	NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"%@的数据---\n%@",title,html);
}








@end
