shared_examples_for 'Broadcastable' do
  it 'broadcasts message through ActionCable' do
    expect(ActionCable.server).to receive(:broadcast).with(channel, anything)
    request
  end
end
