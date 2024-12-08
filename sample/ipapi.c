#include	<stdio.h>
#include	"httpclient.h"
char url[] = "http://ip-api.com/json/?fields=status,city,countryCode,lon,lat";
extern char payload[];
void ser_init();

void main() {

	ser_init();

	http_parse(url);

	http_query("city");
	printf("City:%s\n", payload);

	http_query("countryCode");
	printf("Country Code:%s\n", payload);

	http_query("lon");
	printf("Longitude:%s\n", payload);

	http_query("lat");
	printf("Latitude:%s\n", payload);
}
