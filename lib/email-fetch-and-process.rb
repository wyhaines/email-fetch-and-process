# frozen_string_literal: true

require 'net/imap'
require 'fileutils'
require 'mail'
require 'time'
require 'email-fetch-and-process/version'

# Wrap up the logic to iterate through a bunch of fetch and handle
# jobs. This is the simplest thing that can work code. It could be
# generalized a lot pretty easily.
class EmailFetchAndProcess
  # Class tp encapsulate a fetch and handle job.
  class Job
    def initialize(args = {})
      @args = default_args.merge args
    end

    def default_args
      {
        fetch: ['SUBJECT', ''],
        filename: '',
        action: 'echo FILEPATH',
        subdirectory: nil
      }
    end

    def fetch
      @args[:fetch]
    end

    def filename
      @args[:filename]
    end

    def action
      @args[:action]
    end

    def subdirectory
      @args[:subdirectory]
    end
  end

  attr_accessor :destination

  def initialize(args = {})
    @args = default_args.merge args
    @destination = '/tmp'
  end

  def default_args
    {
      host: '127.0.0.1',
      port: 993,
      tls: true,
      id: nil,
      password: nil,
      mailbox: 'INBOX'
    }
  end

  def imap_connection
    puts "CONNECTING WITH #{@args.inspect}"
    imap = Net::IMAP.new(@args[:host], {:port => @args[:port], :ssl => {:verify_mode => OpenSSL::SSL::VERIFY_NONE}})
    puts "imap.login(#{@args[:id]}, #{@args[:password]})"
    imap.login(@args[:id], @args[:password])
    imap.examine(@args[:mailbox])
    imap
  end

  def handle_parts(parts, job, msg_ids)
    parts.each do |part|
      if !part.parts.empty?
        handle_parts(part.parts, job, msg_ids)
      else
        begin
          name = if job.filename.to_s.empty?
                   part.header[:content_disposition].filename || part.filename rescue part.filename
                 else
                   job.filename
                 end
          name = Mail::Encodings.decode_encode(name, :decode) if name rescue name
        rescue StandardError => e
          puts e, e.backtrace.inspect
          next
        end
        next unless name

        @body_index += 1
        attachment = part
        attachment_path = File.expand_path(File.join(@destination, name))
        attachment_path = nil unless attachment_path =~ /^#{@destination}/
        next unless @destination != attachment_path

        if attachment && attachment_path
          file_path = File.join([@destination, job.subdirectory, name].compact)
          atch = attachment.body.to_s
          FileUtils.mkdir_p File.dirname(file_path) unless FileTest.exist? File.dirname(file_path)
          File.open(file_path, 'wb+') do |fh|
            fh.write atch.respond_to?(:each) ? atch.join : atch
          end
          sha_new = `/usr/bin/shasum "#{file_path}"`.split(/\s+/).first
          sha_old = nil
          FileTest.exist?("#{file_path}.sha") &&
            File.open("#{file_path}.sha", 'r') { |fh| sha_old = fh.read.chomp }
          if sha_new != sha_old
            command_to_run = job.action.gsub(/FILEPATH/, file_path)
            puts command_to_run
            # if system(command_to_run)
            #   File.open("#{file_path}.sha","w+") {|fh| fh.write sha_new }
            # end
          end
        end
      end
    end
  end

  def run(jobs = [])
    @imap = imap_connection

    jobs.each do |job|
      msg_ids = @imap.search(job.fetch)
      next if msg_ids.nil? || msg_ids.empty?
      puts msg_ids.inspect
      begin
        msgs = @imap.fetch(msg_ids, %w[ENVELOPE RFC822])
        msg = msgs.max_by { |m| Time.parse(m['attr']['ENVELOPE'].date) }.attr['RFC822']

        @body_index = 1
      rescue StandardError => err
        puts "Error: #{err}\n#{err.backtrace.join("\n")}"
        @imap = imap_connection
        next
      end
      body = Mail.read_from_string msg
      handle_parts(body.attachments, job, msg_ids) unless body.attachments.empty?
    end

    @imap.close
  end
end
