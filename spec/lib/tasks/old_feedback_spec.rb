require "rails_helper"

describe "old_feedback:delete" do
  subject(:task) { Rake::Task["old_feedback:delete"] }

  before do
    task.reenable
    allow($stdout).to receive(:puts)
  end

  it "deletes feedback older than 2 years" do
    old_feedback = create(:problem_report, created_at: 2.years.ago - 1.day)

    task.invoke

    expect(AnonymousContact.where(id: old_feedback.id)).not_to exist
  end

  it "keeps feedback from within the last 2 years" do
    recent_feedback = create(:problem_report, created_at: 2.years.ago + 1.day)

    task.invoke

    expect(AnonymousContact.where(id: recent_feedback.id)).to exist
  end

  it "reports how much feedback it is deleting" do
    create(:problem_report, created_at: 3.years.ago)

    task.invoke

    expect($stdout).to have_received(:puts).with(/Deleting 1 anonymous contacts/)
  end
end
