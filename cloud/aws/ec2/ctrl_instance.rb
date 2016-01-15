#!/usr/bin/env ruby
#
# EC2インスタンスを作成するモジュール
# ここのラッパー
# http://docs.aws.amazon.com/sdkforruby/api/Aws/EC2/Client.html#create_image-instance_method
require "aws-sdk-ruby"
require 'yaml'

config = YAML.load_file('deploy.yml')
## 以下は必ず入力
# デプロイしたインスタンスID
# ELBのID

deploy_instance_id = config[:ec2][:deploy_instance_id]

EC2CLI = Aws::EC2::Client.new(
  access_key_id: creds['access_key_id'],
  secret_access_key: creds['secret_access_key']
)

## Amiからインスタンスを作る
def create_instance(params)
  EC2CLI.run_instances(
    {
      dry_run: false,
      min_count: params[:max_count],
      max_count: params[:max_count],
      image_id: params[:ami_id],
      security_groups: params[:security_groups],
      instance_type: params[:instance_type],
      ebs_optimized: true
    }
  )
end

## インスタンスのバックアップ
def backup_instance(params)
  resp = EC2CLI.create_image({
    dry_run: false,
    instance_id: params[:instance_id], # required
    name: params[:name], # required
    description: params[:description],
    no_reboot: true,
  })
  return resp.image_id
end

## ELBについているEC2インスタンスの捜査
def get_instances_list_by_elb(params)

  resp = EC2CLI.describe_load_balancers({
    load_balancer_names: params['elb_name'],
    marker: "Marker",
    page_size: 1,
  })

  return resp.load_balancer_descriptions[0].instances
end

# 手順
intances = get_instances_list_by_elb(config[:elb])
now = Time.now.strftime('%Y%m%d')

## デプロイインスタンスのAMI作成
## ami作成
instance = {instance_id: deploy_instance_id , name: "prd#{now}", description: "Backup prd#{now}"}

## インスタンス作成
config[:ami_id] = backup_instance(instance)
resp = create_instance(config)
## 全部が疎通オッケーになるまで繰り返しチェック
resp.instances.each do |instance|
  ## 疎通確認するスクリプト
  # OKならbreak
  # ある程度まってもOKにならないならここでスクリプトは終了する
end


###  TODO
## ELBから古いクラスタをはずす
## ELBに新しいクラスタをひもづける
