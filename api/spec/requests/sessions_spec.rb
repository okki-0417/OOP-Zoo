# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DELETE /session', type: :request do
  subject(:sign_out) { delete '/session' }

  context 'ログイン中のとき' do
    before { post '/dev/session' }

    it '204 でセッションの記録を消し、Cookie の session_id を空にすること' do
      expect { sign_out }.to change(Session, :count).from(1).to(0)
      expect(response).to have_http_status(:no_content)
      expect(cookies[:session_id]).to be_blank
    end
  end

  context 'ログインしていないとき' do
    it '204 を返すこと' do
      sign_out

      expect(response).to have_http_status(:no_content)
    end
  end
end
