require File.expand_path(File.dirname(__FILE__)) + "/../helpers/test_helper.rb"

describe 'A user' do

  # Use email that you created Pivgeon account for
  EMAIL1    = ENV['EMAIL1']
  PASSWORD1 = ENV['PASS1']

  # Use another email that you created Pivgeon account for
  EMAIL2    = ENV['EMAIL2']

  # Use email that no Pivgeon account is created for
  EMAIL3    = ENV['EMAIL3']
  PASSWORD3 = ENV['PASS3']

  PROJECT_NAME             = ENV['PROJECT1'] || "test"
  PROJECT_NAME_WITH_SPACES = ENV['PROJECT2'] || "test project"

  TOKEN = ENV['TOKEN']

  describe "An unregistered user" do
   	   
    before do
      init_mailer(EMAIL3,PASSWORD3) 
    end
      
    it "is not able to crate new story" do
      send_email(EMAIL3,EMAIL3,"#{PROJECT_NAME}@pivgeon.com","Unregistered user creates new story 1","Body")
      wait_for_email( :from => ["pivgeon@pivgeon.com"], :to => [EMAIL3], :subject => "Re: Unregistered user creates new story 1" ) do |body_text|
        assert body_text =~ /You tried to create new story. Unfortunatelly the story hasn't been created due to following errors/
        assert body_text =~ /Unauthorized access/
      end
    end

    it "creates new Pivgeon account" do
      email = "pivgeon_test_user_#{Time.now.hash}#{rand 10000}@example.com"

      visit "http://pivgeon.com/users/new"

      fill_in "Email", :with => email
      fill_in "Pivotal token", :with => TOKEN
      click_button "Create"

      assert has_content?("Congratulations, your account has been created.")
    end

    describe "can't create new pivgeon account" do

      before do
        visit "http://pivgeon.com/users/new"
      end

      it "due to mising data" do        
        fill_in "Email", :with => ""
        fill_in "Pivotal token", :with => ""
        
        click_button "Create"

        assert has_css?("div.formError", :text => "Email can't be blank")
        assert has_css?("div.formError", :text => "Token can't be blank")
      end

      it "due to taken email" do
        fill_in "Email", :with => EMAIL1
        fill_in "Pivotal token", :with => TOKEN

        click_button "Create"

        assert has_css?("div.formError", :text => "Email address is already taken")
      end

      it "due to invalid token" do
        fill_in "Email", :with => "someemail@example.com"
        fill_in "Pivotal token", :with => "invalidtoken"

        click_button "Create"

        assert has_css?("div.formError", :text => "Token is invalid")
      end

    end
      
  end

  describe "A registered user" do

    before do
      init_mailer(EMAIL1,PASSWORD1)
    end

    it "creates new story owned by him" do
      send_email(EMAIL1,EMAIL1,"#{PROJECT_NAME}@pivgeon.com","Add new feature","Some more detailed explanation")
      wait_for_email( :from => ["pivgeon@pivgeon.com"], :to => [EMAIL1], :subject => "Re: Add new feature") do |body_text|
        assert body_text =~ /You have created new story .+Add new feature.+/
      end
    end

    it "creates new story owned by other user" do
      send_email(EMAIL1,EMAIL2,"#{PROJECT_NAME}@pivgeon.com","Implement new feature","Some more detailed explanation")
      wait_for_email( :from => ["pivgeon@pivgeon.com"], :to => [EMAIL1], :subject => "Re: Implement new feature") do |body_text|
        assert body_text =~ /You have created new story .+Implement new feature.+/
      end
    end

    it "creates new story for project with space" do
      project_name = PROJECT_NAME_WITH_SPACES.split(' ').join
      send_email(EMAIL1,EMAIL1,"#{project_name}@pivgeon.com","Fix the bug","Some more detailed explanation")
      wait_for_email(:from => ["pivgeon@pivgeon.com"], :to => [EMAIL1], :subject => "Re: Fix the bug") do |body_text|
        assert body_text =~ /You have created new story .+Fix the bug+/
      end
    end

    describe "is not able to create new story" do

      it "due to not existing member" do
        send_email(EMAIL1,EMAIL3,"#{PROJECT_NAME}@pivgeon.com","Add second feature","Some more detailed explanation")
        wait_for_email(:from => ["pivgeon@pivgeon.com"], :to => [EMAIL1], :subject => "Re: Add second feature") do |body_text|
          assert body_text =~ /A person that you try to assign to the story is not a project member/
        end
      end

      it "due to not existing project" do
        send_email(EMAIL1,EMAIL1,"ertyuasdafa@pivgeon.com","Add third feature","Some more detailed explanation")
        wait_for_email(:from => ["pivgeon@pivgeon.com"], :to => [EMAIL1], :subject => "Re: Add third feature") do |body_text|
          assert body_text =~ /Project 'ertyuasdafa' that you try to create this story for does not exist/
        end
      end

    end

  end
 
  
end
