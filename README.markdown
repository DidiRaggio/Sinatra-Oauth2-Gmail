## Create gmail credentials

go to https://console.developers.google.com/flows/enableapi?apiid=gmail create project and automatically turn on the API.

In library click "GMAIL API" link, and enable

In library click "CONTACT API" link, and enable

then Go to credentials, at the top of the page, select the OAuth consent screen tab. Select an Email address, enter a Product name if not already set, and click the Save button.

Select the Credentials tab, click the Create credentials button and select OAuth client ID.

Select the application type Other, enter the name "Gmail API Srapper", and click the Create button.

The resulting dialog, gives you the client_id and client_secret (these will later be used in the application).
If you need to copy them agian just click "Gmail API Srapper" and they will be made available.


There are 2 possible options for generating the oauth2 tokens necessary for the gmail scraper, I highly recomend the first,
as the second requires you to copy links and paste them into the command line.

OPTION1:

## Run It!

To get this puppy running you just need type into the console:

```bundle install```

then

```rackup```
rackup

and then head over to http://localhost:9292

There you can follow the links to create the oauth2 tokens (THAT MUST BE GENERATED TO RUN THE GMAIL SCRAPER).
This will generate a env.yaml file that contains all the tokens needed to run the gmail scraper.
Then you can run the scraper by the following links and filling out the forms.
this downloads the attached file (how ever you wished to name it) in scrapes/output


OPTION2:

-GENERATION OF OAUTH2 TOKENS 
   run the oauth2full method from the oauth2.rb file

   ex: $ ruby -r "./oauth2.rb" -e "oauth2full('243599753706-*************.apps.googleusercontent.com', '7PF*********dN')" 

   follow the instructions promted.

	this will generate a env.yaml file that contains all the tokens needed to run the gmail scraper

-GMAIL SCRAPER
	run the get_attachment_from method from the gmail_scraper.rb

	ex: $ ruby -r "./gmail_scraper.rb" -e "get_attachment_from('didiraggio@gmail.com', 'outputtedCSV.csv')"

	this downloads the attached file as 'outputtedCSV.csv' in scrapes/output