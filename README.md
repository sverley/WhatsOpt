# WhatsOpt
WhatsOpt is a web application allowing to define and share multi-disciplinary analyses in terms of disciplines and data exchange. It was develop at ONERA, in the context of overall aircraft design activities. From that high-level definition, users can generate source code skeleton required to plug the actual implementation of their disciplines and get an actual executable model of the concept under study. WhatsOpt allows to generate code to run numerical methods such as sensitivity analysis, design of experiments and optimizations.

## Resources

* [WhatsOpt paper](https://www.researchgate.net/publication/333806928_WhatsOpt_a_web_application_for_multidisciplinary_design_analysis_and_optimization): WhatsOpt: a web application for multidisciplinary design analysis and optimization.
* [WhatsOpt doc](https://github.com/OneraHub/WhatsOpt-Doc): Notebooks and examples
* [WhatsOpt videos](https://www.youtube.com/playlist?list=PLhWP4LJdKyGcFZyvsNLU4s2_sdmTSGVeo): Tutorials

## Citation
If you happen to find WhatsOpt useful for your research, it will be appreciated if you cite us with:
>Lafage, R., Defoort, S., & Lefebvre, T. (2019). _WhatsOpt: a web application for multidisciplinary design analysis and optimization. In AIAA Aviation 2019 Forum (p. 2990)._

or if you use Bibtex, you can use the following entry:
<pre>
@inproceedings{lafage2019whatsopt,
  title={WhatsOpt: a web application for multidisciplinary design analysis and optimization},
  doi={10.2514/6.2019-2990}, 
  url={https://doi.org/10.2514/6.2019-2990}
  author={Lafage, R{\'e}mi and Defoort, Sebastien and Lefebvre, Thierry},
  booktitle={AIAA Aviation 2019 Forum},
  pages={2990},
  year={2019}
}
</pre>

# Installation

## Prerequisites
* Ruby 2.5+ ([rvm](https://rvm.io/) recommended to manage Ruby environments)
* Python 3.6+ ([Anaconda](https://www.anaconda.com/distribution/) recommended to manage Python environments)
* Node.js 8.16.0+
* Yarn 1.x+

## Setup
WhatsOpt rails application setup:
<pre>
  git clone https://github.com/OneraHub/WhatsOpt
</pre>
WhatsOpt command line interface setup:
<pre>
  pip install wop
</pre>
The <code>wop</code> package pulls also Python dependencies used by WhatsOpt application, specially the [OpenMDAO framework](https://openmdao.org) which is currently the execution framework used by WhatsOpt. See also [optional setup section](#optional-setup) for further installtion instructions.

### Development setup
This is the typical development mode of a Rails application, it is simpler to install than a typical production server (with a full-blown web server and database engine). It will allow you to get started with WhatsOpt in your local environment.   

<pre>
  cd WhatsOpt
  bundle install
  rails db:migrate
  rails db:seed
  cp config/database.yml.example config/database.yml
  rails s -b 0.0.0.0
</pre>

Then you can visit the http://localhost:3000 url and log in with the default user login/passwd: whatsopt/whatsopt!

You can also run the test suite with:

<code>
  rails test
</code>

### Production setup
Ruby on Rails ecosystem allows various options for application server configuration and deployment. Refer to related Ruby on Rails documentation to know your deployment options.

The guide lines summarized below are related to the deployment of WhatsOpt on [ONERA server](https://ether.onera.fr/whatsopt). It relies on:
* Apache Server
* Passenger (aka module for rails)
* MySQL

Once those prerequisites are installed on your server, you have to fit:
* <code>config/environments/configuration.yml</code>
* <code>config/environments/database.yml</code>
* <code>config/environments/production.rb</code>
* <code>config/environments/ldap.yml</code> (if needed) 

For deployment in production capistrano utility is used, you have to fit to your needs the following files:
* <code>config/deploy.rb</code>
* <code>config/deploy/production.rb</code>

then the deployment is one command line away:
<pre>
  cap production deploy
</pre>

## Optional setup
To get additional features you need to install the following Python packages:
* SMT: enable metamodel creation
* SALib: enable sensitivity analysis operations
* Thrift: enable server creation and remote operations on local network

<pre>
  pip install smt==0.3.4 salib==1.3.3 thrift==0.11.0
</pre>

## Contact

WhatsOpt was created by Rémi Lafage in the context of internal research projects at [ONERA, the French Aerospace Lab](https://www.onera.fr/en). 

Contact: remi [dot] lafage [at] onera [dot] fr
