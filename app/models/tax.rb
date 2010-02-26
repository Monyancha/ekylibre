# = Informations
# 
# == License
# 
# Ekylibre - Simple ERP
# Copyright (C) 2009-2010 Brice Texier, Thibaud Mérigon
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
# 
# == Table: taxes
#
#  account_collected_id :integer          
#  account_paid_id      :integer          
#  amount               :decimal(16, 4)   default(0.0), not null
#  company_id           :integer          not null
#  created_at           :datetime         not null
#  creator_id           :integer          
#  deleted              :boolean          not null
#  description          :text             
#  id                   :integer          not null, primary key
#  included             :boolean          not null
#  lock_version         :integer          default(0), not null
#  name                 :string(255)      not null
#  nature               :string(8)        not null
#  reductible           :boolean          default(TRUE), not null
#  updated_at           :datetime         not null
#  updater_id           :integer          
#

class Tax < ActiveRecord::Base
  belongs_to :company
  belongs_to :account_collected, :class_name=>Account.name
  belongs_to :account_paid, :class_name=>Account.name
  has_many :prices

  validates_inclusion_of :nature, :in=>%w( amount percent )
  validates_presence_of :account_collected_id
  validates_presence_of :account_paid_id

  attr_readonly :nature, :company_id #, :amount

  def validate
    errors.add(:amount, :included_in, :minimum=>0.to_s, :maximum=>1.to_s) if (self.amount < 0 or self.amount > 1) and self.percent?
  end

  def before_destroy
    Tax.create!(self.attributes.merge({:deleted=>true, :name=>self.name+" ", :company_id=>self.company_id})) 
  end
  
  def compute(amount, with_taxes=false)
    if self.percent? and with_taxes
      amount.to_f / (1 + 1.0/self.amount.to_f)
    elsif self.percent?
      amount.to_f*self.amount.to_f
    elsif self.amount?
      self.amount
    end
  end

  def percent?
    return (self.nature == "percent")
  end
  
  def amount?
    self.nature == "amount"
  end

  def self.natures
     [:percent, :amount].collect{|x| [tc('natures.'+x.to_s), x] }
  end

  def nature_label
    tc('natures.'+self.nature.to_s)
  end
  
end
