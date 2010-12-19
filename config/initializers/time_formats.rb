# encoding: UTF-8
date_formats = {
  :date      => '%d/%m/%Y',
  :posted    => '%d/%m/%Y à %H:%M',
  :norloge   => '%H:%M:%S',
  :timestamp => '%Y%m%d%H%M%S'
}

Time::DATE_FORMATS.update(date_formats)
Date::DATE_FORMATS.update(date_formats)
