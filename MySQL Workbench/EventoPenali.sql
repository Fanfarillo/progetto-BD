set global event_scheduler = on;
CREATE event IF NOT EXISTS `cleanup_penali_tariffe`
	on schedule
	every 730 day
		on completion preserve

	do
		delete from `penale` where `data_restituzione` < (NOW() - interval 730 day);
		delete from `tariffa` where `restituzione` < (NOW() - interval 730 day);