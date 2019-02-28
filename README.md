# USNO_lunar_watch
![lunar watch screen](https://s3.amazonaws.com/www.imipolex-g.com/screenshots/lunar_screenshot.png "Screen")

A minimalist Watch app that makes a REST call to the United States Naval Observatory Astronomical Applications web service. It decodes the JSON to get the lunar rise/transit/set times, and grabs a generated image of the lunar disk. Uses Core Location to figure out where you are observing from.

https://aa.usno.navy.mil/data/docs/api.php#rstt

The US Navy recently did something with their SSL cert- I had to import the site cert into Keychain on my Mac and add it to the key profile on my phone. I had to find a DoD Root CA 3 cert online and import it. The one I found was in an archive named Certificates_PKCS7_V5.4_DoD. This looks like it might be an updated one:

http://iasecontent.disa.mil/pki-pke/Certificates_PKCS7_v5.5_DoD.zip

## DISCLAIMER!
This is for experimentation only- do not use for any critical purpose! The author disclaims any warranty or liability for its use.
