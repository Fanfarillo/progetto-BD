set global event_scheduler = on;
CREATE event IF NOT EXISTS `cleanup_turni_malattie`
	on schedule
	every 30 day
		on completion preserve

	do
		delete from `malattia` where `data_malattia` < (NOW() - interval 30 day);
		delete from `turno` where `data` < (NOW() - interval 30 day);