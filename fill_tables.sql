-- user might need rights to read data on server
DO $$
DECLARE
  -- change to full path to the same directory on your system
  dir_path VARCHAR := '/home/alina/3rd_course/bd/datasets';
BEGIN
  call import_csv('clients', format('%s/clients.csv', dir_path), ',');
--   call import_csv('buildings', format('%s/buildings.csv', dir_path));
--   call import_csv('service_type', format('%s/service_type.csv', dir_path));
--   call import_csv('type_of_guest', format('%s/type_of_guest.csv', dir_path));
--   call import_csv('room_types', format('%s/room_types.csv', dir_path));
--   call import_csv('rooms', format('%s/rooms.csv', dir_path));
--   call import_csv('complaints', format('%s/complaints.csv', dir_path));
--   call import_csv('reservations', format('%s/reservations.csv', dir_path));
--   call import_csv('room_reservations', format('%s/room_reservations.csv', dir_path));
--   call import_csv('services', format('%s/services.csv', dir_path));
--   call import_csv('services_used', format('%s/services_used.csv', dir_path));
--   call import_csv('service_in_building', format('%s/service_in_building.csv', dir_path));
END;
$$;