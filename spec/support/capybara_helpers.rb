module CapybaraHelpers
  def login_helper(email, password)
    visit log_in_path
    within('form.login') do
      fill_in "Email",    with: email
      fill_in "Password", with: password
    end

    click_button "Login"
  end
end
