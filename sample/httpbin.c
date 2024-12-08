#include	<stdio.h>
#include	<string.h>
#include	"httpclient.h"
char url[]="https://httpbin.org/";

extern char payload[];
void ser_init();

void main() {
	char qbuf[40];

	ser_init();
	printf("HTTPBIN\n");

	strcpy(qbuf, url);
	strcat(qbuf, "get");
	http_parse(qbuf);

	printf("\n>QUERY Test\n");
	http_query("origin");
	printf("%s\n", payload);
	http_query("headers/User-Agent");
	printf("%s\n", payload);
	http_query("headers/Accept-Encoding");
	printf("%s\n", payload);

	printf("\n>POST Test\n");
	http_query("origin");
	strcpy(qbuf, url);
	strcat(qbuf, "post");
	http_post(qbuf, "name", "shunkita");
	http_query("json/name");
	printf("%s\n", payload);

	printf("\n>PUT Test\n");
	strcpy(qbuf, url);
	strcat(qbuf, "put");
	http_put(qbuf, "name", "momotaro");
	http_query("json/name");
	printf("%s\n", payload);

	printf("\n>DELETE Test\n");
	strcpy(qbuf, url);
	strcat(qbuf, "delete");
	http_delete(qbuf, "{\"key\":\"value\"}");
	printf("%s\n", payload);
}
