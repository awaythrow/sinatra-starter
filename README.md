# sinatra-starter

Opinionated tool for creating a Sinatra app with GitHub Actions CI and Weaveworks Flux CD.


## Getting Started

Clone this git repository. It contains tools and templates to assist in creating, testing, building, and deploying your app.

```bash
git clone git@github.com:awaythrow/sinatra-starter.git
cd sinatra-starter
./sinatra-starter -h

Sinatra Starter Usage

  ./sinatra-starter setup                                           Installs prerequisites. Note: requires MacOS see README.md

  ./sinatra-starter new -a <name> -r <git_repo> [-n k8s_namespace]  Creates a new Sinatra app with name using git_repo for the remote origin

```

### Install developer tools

#### Automated install

If you're on MacOS `sinatra-starter` can install developer tools for you.

```bash
cd sinatra-starter
./sinatra-starter setup

...snip...

Setup complete.

  Please refresh your shell by opening a new window or sourcing the
  appropriate shell startup file.

  source ~/.bash_profile
  or
  source ~/.zshrc
```

#### Manual setup

On Linux do the following to setup prerequisites.

**Install Docker Desktop**

https://docs.docker.com/get-docker/

**Install ruby-build dependencies**

https://github.com/rbenv/ruby-build/wiki#suggested-build-environment

**Setup asdf**

```bash
# Install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
echo '. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
source ~/.bash_profile

# Import asdf plugins
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf plugin-add minikube https://github.com/alvarobp/asdf-minikube.git
asdf plugin-add kubectl https://github.com/Banno/asdf-kubectl.git
asdf plugin-add helm https://github.com/Antiarchitect/asdf-helm.git
asdf plugin-add helmfile https://github.com/feniix/asdf-helmfile.git
asdf plugin-add fluxctl https://github.com/stefansedich/asdf-fluxctl

# Import the Node.js release team's OpenPGP keys to main keyring:
bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'

# Install tools
cd sinatra-starter
asdf install
```


### Setup Github

**Create a new GitHub personal access token**

This token is used later for GitHub Actions workflow to push docker images to the container registry.

1. 	Visit: https://github.com/settings/tokens
2. 	Click **Generate new token**
3. Enter a name such as `github-actions`
4. Check **write:packages** and **repo**
5. Click **Generate token**
6. Save the token in a text editor for later

**Create a new empty Github repository**

Using the following link create a new repository which will contain the Sinatra project.

https://github.com/new

**Add the personal access token to the repository's secrets**

1. From the new repository on Github click the **Settings** menu item in the top right.
1. Select **Secrets** from the menu on the left
2. Click **New secret** on the top right
3. Enter `CR_PAT` for the **Name**
4. Paste your personal access token created in an earlier step for the **Value**
5. Click **Add secret**


### Generate a new project

Sinatra-starter outputs the new project in the current working directory. Change directory to an approriate path and run the following, modifying the path to `sinatra-starter` as necessary.

For example, here we create a new sinatra project named userlist.

```bash
./sinatra-starter/sinatra-starter new -a userlist -r https://github.com/awaythrow/userlist.git

cd userlist
ls -l
total 56
-rw-r--r--  1 user  staff   318 Oct 25 18:45 Dockerfile
-rw-r--r--  1 user  staff   500 Oct 25 18:45 Gemfile
-rw-r--r--  1 user  staff  2257 Oct 25 18:45 Gemfile.lock
-rw-r--r--  1 user  staff    11 Oct 25 18:45 README.md
-rw-r--r--  1 user  staff    76 Oct 25 18:45 Rakefile
drwxr-xr-x  5 user  staff   160 Oct 25 18:45 app
drwxr-xr-x  8 user  staff   256 Oct 25 18:45 bin
drwxr-xr-x  4 user  staff   128 Oct 25 18:45 config
-rw-r--r--  1 user  staff    58 Oct 25 18:45 config.ru
drwxr-xr-x  3 user  staff    96 Oct 25 18:48 db
drwxr-xr-x  5 user  staff   160 Oct 25 18:45 deploy
-rw-r--r--  1 user  staff   279 Oct 25 18:45 docker-compose.test.yml
drwxr-xr-x  3 user  staff    96 Oct 25 18:45 lib
drwxr-xr-x  6 user  staff   192 Oct 25 18:45 public
drwxr-xr-x  5 user  staff   160 Oct 25 18:45 spec
drwxr-xr-x  3 user  staff    96 Oct 25 18:45 vendor
```

### Add a model and controller methods

Create a new file `models/user.rb` with the following content.

```ruby
class Users < ActiveRecord::Base
end
```

Create a db migration stub.

```bash
bin/rake db:create_migration NAME=create_users
```

Add the following to the newly created migration file in `db/migrate`

```ruby
class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :firstname
      t.string :lastname
      t.string :email
    end
  end
end
```

Run the migration

```bash
npm run db.up
bin/rake db:create db:migrate
```

Add the following methods to the `App` class in `app.rb`

```ruby

  get '/users' do
    users = Users.all
    json users
  end

  get '/users/:id' do
    user = Users.find(params[:id])
    json user
  end

  post '/users' do
    user = Users.create(params)
    status 201
    json user
  end

  put '/users/:id' do
    user = Users.find(params[:id])
    user.update(params)
    status 204
    json user
  end

  delete '/users/:id' do
    user = Users.destroy(params[:id])
    status 202
    json user
  end
```

Start the server

```
bin/rerun bin/puma

21:58:37 [rerun] Userlist launched
21:58:37 [rerun] Rerun (60600) running Userlist (60748)
Puma starting in single mode...
* Version 5.0.2 (ruby 2.7.2-p137), codename: Spoony Bard
* Min threads: 0, max threads: 5
* Environment: development
* Listening on http://0.0.0.0:9292
Use Ctrl-C to stop
21:58:39 [rerun] Watching . for **/*.{rb,js,coffee,css,scss,sass,erb,html,haml,ru,yml,slim,md,feature,c,h} with Darwin adapter
```

Confirm it's working

```bash
curl http://127.0.0.1:9292/
Welcome to the Sinatra Template!

curl http://127.0.0.1:9292/users
[]

curl -X POST 'http://0.0.0.0:9292/users' --data-raw 'firstname=hello&lastname=there&email=hellothere@domain.com'
{"id":1,"firstname":"hello","lastname":"there","email":"hellothere@domain.com"}

curl http://127.0.0.1:9292/users
[{"id":1,"firstname":"hello","lastname":"there","email":"hellothere@domain.com"}]
```

### Add some tests

The template is setup to use rspec and rack-test for testing.  It already includes a basic test.  We can expand those tests now for the additional methods we added to the controller.

Add the following to spec/app_spec.rb

```ruby
  describe "CRUD users" do
    it "returns valid json" do
      get "/users"
      expect(last_response).to be_ok
      expect(last_response.header['Content-Type']).to include 'application/json'
      expect(JSON.parse last_response.body).to_not be_nil
    end

    context "create several users" do
      before do
        @users = [
          { firstname: 'user', lastname: 'one', email: 'userone@example.com' },
          { firstname: 'user', lastname: 'two', email: 'usertwo@example.com' },
          { firstname: 'user', lastname: 'three', email: 'userthree@example.com' },
        ]
        @users.map! { |user| user.transform_keys(&:to_s) }
        @users.each do |user|
          post "/users", user
        end
      end
      it "returns all the users" do
        get "/users"
        expect(last_response).to be_ok

        response_data = JSON.parse(last_response.body)
        response_data.each { |h| h.delete("id") }
        expect(response_data).to include(*@users)
      end
    end

    context "delete users" do
      before do
        @users = [
          { firstname: 'user', lastname: 'one', email: 'userone@example.com' },
          { firstname: 'user', lastname: 'two', email: 'usertwo@example.com' },
          { firstname: 'user', lastname: 'three', email: 'userthree@example.com' },
        ]
        @users.map! { |user| user.transform_keys(&:to_s) }
        @users.each do |user|
          post "/users", user
        end
      end
      it "deletes users" do
        get "/users"
        expect(last_response).to be_ok

        response_data = JSON.parse(last_response.body)
        response_data.each do |user|
          delete "users/#{user['id']}"
          expect(last_response.status).to eq 202
        end
      end
    end
  end
```

Run the rake task to create the test db and then run the tests.

```bash
APP_ENV=test bin/rake db:create db:migrate
bin/rspec

Randomized with seed 56619

App
  responds with a welcome message
  CRUD users
    returns valid json
    create several users
      returns all the users
    delete users
      deletes users

Top 4 slowest examples (0.163 seconds, 97.3% of total time):
  App CRUD users returns valid json
    0.07867 seconds ./spec/app_spec.rb:13
  App CRUD users delete users deletes users
    0.04378 seconds ./spec/app_spec.rb:54
  App CRUD users create several users returns all the users
    0.02496 seconds ./spec/app_spec.rb:32
  App responds with a welcome message
    0.01559 seconds ./spec/app_spec.rb:6

Finished in 0.16758 seconds (files took 0.79336 seconds to load)
4 examples, 0 failures

Randomized with seed 56619
```

### Push to Github

Once we've pushed to Github, our workflow will run, build the docker image, and push it to Github packages.

We need to make the package public after that so our Kubernetes server can pull it without additional configuration.

```
git add -A
git commit -m 'Add users model and controller methods'
git push origin main
```

1. Goto your repository and click **Actions** on the top menu bar
2. Wait for your workflow to complete.
3. Click your user icon in the top right and select **Your profile**
4. Click **Packages** on the menu at the top
5. Click on your newly uploaded docker image
6. Click the **Package Settings** button on the right
7. Click **Make public**


## Continuously Deploy to Kubernetes

Now that was have continuous integration building and testing our image we can move on to deploying it.

### Setup Kubernetes cluster

If you do not have a Kubernetes cluster you would like to use for this you can use `minikube start` to start a local cluster.

Use kubectl to create a secret to store a random password for postgres.  We do this outside of the helm release process because there is currently no good way for a helm release to generate a secret that does not change on each upgrade.

```bash
kubectl create secret generic -n default db-creds --from-literal=postgresql-password=$(uuidgen)
```

### Bootstrap Flux and Helm-operator

We can use helmfile to bootstrap flux and helm-operator.  Once those apps are running they will watch our repository and docker repo for changes.

```bash
cd deploy/helmfile
helmfile apply
```

Get the public key generated by Flux and add it to your Github repository.

```bash
kubectl -n default logs deployment/flux | grep identity.pub | cut -d '"' -f2
```
1. Copy the result of the command above
2. Go to your Github repository and click **Settings** from the top menu
3. Click **Deploy keys** on the menu on the left
4. Click the **Add deploy key** button in the top right.
5. Name the key `flux` and paste the key contents from the command above
6. Check the **Allow write access** box
7. Click **Add key**

```bash
fluxctl sync

Synchronizing with ssh://git@github.com/awaythrow/userlist.git
Revision of main to apply is 8e15498
Waiting for 8e15498 to be applied ...
Done.

fluxctl list-workloads

WORKLOAD                                 CONTAINER            IMAGE                                              RELEASE   POLICY
default:deployment/flux                  flux                 docker.io/fluxcd/flux:1.20.2                       ready
default:deployment/flux-memcached        memcached            memcached:1.5.20                                   ready
default:deployment/helm-operator         flux-helm-operator   docker.io/fluxcd/helm-operator:1.2.0               ready
default:deployment/userlist              sinatra-app          ghcr.io/awaythrow/userlist:main                    ready
default:helmrelease/postgres                                                                                     deployed
default:helmrelease/userlist             chart-image          ghcr.io/awaythrow/userlist:main                    deployed  automated
default:statefulset/postgres-postgresql  postgres-postgresql  docker.io/bitnami/postgresql:11.9.0-debian-10-r48  ready

```

### Continuously deliver a change

Update `views/index.erb` to add a basic form.

```html
Welcome to the Sinatra Template!

<br><a href='/users'>List users</a><br><br>

<form action="/users" method="post">
  <label for="firstname">First name:</label>
  <input type="text" id="firstname" name="firstname"><br><br>
  <label for="lastname">Last name:</label>
  <input type="text" id="lastname" name="lastname"><br><br>
  <label for="email">Email:</label>
  <input type="text" id="email" name="email"><br><br>
  <input type="submit" value="Submit">
</form>
```

Commit and tag the release.

```bash
git add views/index.erb
git commit -m 'Add form to index'
git push origin main
git tag v0.1.0
git push origin v0.1.0
```

Wait for the workflow to finish and flux to notice the new image.  Note we're now running our newly tagged image.

```
fluxctl list-workloads

WORKLOAD                                 CONTAINER            IMAGE                                              RELEASE   POLICY
...
default:deployment/userlist              sinatra-app          ghcr.io/awaythrow/userlist:0.1.0                   ready
```