#!/usr/bin/env ruby
#
# EC2インスタンスを作成するモジュール
# ここのラッパー
# http://docs.aws.amazon.com/sdkforruby/api/Aws/EC2/Client.html#create_image-instance_method
require "aws-sdk-ruby"

module SROCK_AWS_TOOLSET
  module EC2
    class CT

      EC2CLI = Aws::EC2::Client.new(
        access_key_id: creds['access_key_id'],
        secret_access_key: creds['secret_access_key']
      )

      ## 無からインスタンスを作る
      def create_instance(params)
        EC2CLI.run_instances(
          {
            # テスト動作 trueかfalseで指定
            dry_run: params[:dry_run],
            # 起動させたい最小インスタンス。数字指定。
            min_count: params[:min_count],
            # 起動したい最大インスタンス。数字。
            max_count: params[:max_count],
            key_name: params[:key_name],
            # セキュリティグループ名。配列か文字列で指定。
            security_groups: params[:security_groups],
            # セキュリティグループIDで指定する場合。配列と数字。これ上と合わせて使えるのかな。
            security_group_ids: params[:security_group_ids],
            user_data: params[:user_data],
            instance_type: params[:instance_type],
            placement: params[:placement],
            ebs_optimized: true
          }
        )
      end

      ## 既存イメージのバックアップ
      def backup_instance(params)
        EC2CLI.create_image({
          dry_run: params[:dry_run],
          instance_id: params[:instance_id], # required
          name: params[:name], # required
          description: params[:description],
          no_reboot: params[:no_reboot],
          block_device_mappings: [
            {
              virtual_name: "String",
              device_name: "String",
              ebs: {
                snapshot_id: "String",
                volume_size: 1,
                delete_on_termination: true,
                volume_type: "standard", # accepts standard, io1, gp2
                iops: 1,
                encrypted: true,
              },
              no_device: "String",
            },
          ],
        })
      end
    end
  end
end
