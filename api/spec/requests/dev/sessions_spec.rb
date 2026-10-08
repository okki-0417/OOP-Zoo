# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /dev/session', type: :request do
  subject(:sign_in) { post '/dev/session', headers: { 'User-Agent' => 'RSpec' } }

  context 'ユーザーがまだいないとき' do
    it '204 でユーザーを1人作り、そのユーザーのセッションを User-Agent 付きで記録すること' do
      sign_in

      expect(response).to have_http_status(:no_content)
      expect(Session.sole).to have_attributes(user: User.sole, user_agent: 'RSpec')
    end
  end

  context 'ユーザーがすでにいるとき' do
    let!(:user) { create(:user) }

    it 'ユーザーを増やさず、既存のユーザーのセッションを記録すること' do
      expect { sign_in }.not_to change(User, :count)
      expect(Session.sole.user).to eq(user)
    end
  end

  it 'Set-Cookie で session_id を HttpOnly・SameSite=Lax の Cookie として返すこと' do
    sign_in

    expect(response.headers['Set-Cookie']).to include('session_id=', 'httponly', 'samesite=lax')
  end
end
