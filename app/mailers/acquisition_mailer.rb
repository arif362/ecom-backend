class AcquisitionMailer < ApplicationMailer
  def send_csv_attachment(csv_data, file_name, subject = 'Acquisition Payment Status Update Report File', body = '')
    attachments[file_name] = {mime_type: 'text/csv', content: csv_data}
    mail(to: ENV['EMAILS_TO_SEND_ACQUISITION_REPORTS'].to_s.split, subject: subject, body: body)
  end
end
