#ifndef	HTTPCLIENT_H
#define HTTPCLIENT_H
#define	CMD_PARSE	1
#define CMD_QUERY  2
#define CMD_POST  3
#define CMD_PUT  4
#define CMD_DELETE  5
#define	CMD_SEND_URL 6
#define CMD_CLOSE 7
#define CMD_EXIT 99
void http_parse(char *s); 
void http_query(char *s);
void http_post(char *url, char *key, char *value);
void http_put(char *url, char *key, char *value);
void http_delete(char *url, char *element);
void http_close();
void http_exit();
//
void send_request(char *s, int len);
void send_url(char *url);
#endif
