#include	<stdio.h>
#include	<string.h>
#include	"httpclient.h"
#include	"sscserial.h"

char payload[1024];
char send_buf[1024];

void send_request(char *s, int len) {
	int i;

	ser_put(0x01);
	ser_put(len & 0xff);
	ser_put(len >> 8);
	for (i=0; i < len; i++) {
		ser_put(*s++);
	}
}

void send_url(char *url) {
	send_buf[0] = CMD_SEND_URL;
	strcpy(&send_buf[1], url);
	send_request(send_buf, strlen(url)+1);
}
//
void http_parse(char *s) {
	send_buf[0] = CMD_PARSE;
	strcpy(&send_buf[1], s);
	send_request(send_buf, strlen(s)+1);
}
void http_query(char *s) {
	send_buf[0] = CMD_QUERY;
	strcpy(&send_buf[1], s);
	memset(payload, 0x00, strlen(payload));
	send_request(send_buf, strlen(s)+1);
	recv_response(payload);
}
//
void http_post(char *url, char *key, char *value) {
	send_url(url);
	send_buf[0] = CMD_POST;
	sprintf(&send_buf[1], "{\"%s\":\"%s\"}", key, value);
	send_request(send_buf, strlen((char *)&send_buf[1])+1);
}
void http_put(char *url, char *key, char *value) {
	send_url(url);
	send_buf[0] = CMD_PUT;
	sprintf(&send_buf[1], "{\"%s\":\"%s\"}", key, value);
	send_request(send_buf, strlen((char *)&send_buf[1])+1);
}
void http_delete(char *url, char *element) {
	send_url(url);
	send_buf[0] = CMD_DELETE;
	strcpy(&send_buf[1], element);
	send_request(send_buf, strlen(element)+1);
}
	
void http_close() {
	send_buf[0] = CMD_CLOSE;
	send_buf[1] = 0x00;
	send_request(send_buf, 1);
}
void http_exit() {
	send_buf[0] = CMD_EXIT;
	send_buf[1] = 0x00;
	send_request(send_buf, 1);
}
