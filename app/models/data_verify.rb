class DataVerify < ActiveRecord::Base
  
  # 是否是正整数
  def self.is_positive_integer(obj)  
    check = (obj =~/^\d+$/ )
    if !check || obj.to_i == 0
      return false
    else
      return true
    end
  end
  
  # 是否是正整数
  def self.is_positive_integer_with_zero(obj)  
    check = (obj =~/^\d+$/ )
    if !check
      return false
    else
      return true
    end
  end
   
  # 是否是正浮点数
  def self.is_positive_float(obj)
    check = (obj =~/^\d+(\.\d+){0,1}$/)
    if !check || obj.to_f==0
      return false
    else
      return true
    end
  end
    
  # 是否是浮点数
  def self.is_float(obj)
    check = (obj =~/^(\-){0,1}\d+(\.\d+){0,1}$/)
    if !check
      return false
    else
      return true
    end
  end
  
  def self.verify_date(str)
    if (str =~ /^\d{4}[\-\.\/]\d{1,2}[\-\.]\d{1,2}$/ ) 
      return true
    else
      return false
    end
  end
  
  def self.equal_day(day1, day2)
    if day1.year == day2.year && day1.month == day2.month && day1.day == day2.day
      return true
    else
      return false
    end
  end
  
end
