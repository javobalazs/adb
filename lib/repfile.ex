#
# defmodule Repfile do
#   require Logger
#
#   def open(filePath, opts) do
#     fd = :file.open(filePath, opts)
#     Logger.info("| open | #{filePath} | opts | #{inspect opts} | result | #{inspect fd} |")
#     fd
#   end
#
#   def rename(filePath, delFile) do
#     res = :file.rename(filePath, delFile)
#     Logger.info("| rename | #{filePath} | to | #{delFile} | result | #{inspect res} |")
#     res
#   end
#
#   def delete(delFile) do
#     res = :file.delete(delFile)
#     Logger.info("| delete | #{delFile} | result | #{inspect res} |")
#     res
#   end
#
#   def del_dir(dir) do
#     res = :file.del_dir(dir)
#     Logger.info("| del_dir | #{dir} | result | #{inspect res} |")
#     res
#   end
#
#   def list_dir(dir) do
#     res = :file.list_dir(dir)
#     Logger.info("| list_dir | #{dir} | result | #{inspect res} |")
#     res
#   end
#
#   def read_file_info(file) do
#     res = :file.read_file_info(file)
#     Logger.info("| read_file_info | #{file} | result | #{inspect res} |")
#     res
#   end
#
#   def position(fd, pos) do
#     res = :file.position(fd, pos)
#     Logger.info("| position | #{inspect fd} | pos | #{pos} | result | #{inspect res} |")
#     res
#   end
#
#   def close(fd) do
#     res = :file.close(fd)
#     Logger.info("| close | #{inspect fd} | result | #{inspect res} |")
#     res
#   end
#
#   def sync(fd) do
#     res = :file.sync(fd)
#     Logger.info("| sync | #{inspect fd} | result | #{inspect res} |")
#     res
#   end
#
#   def truncate(fd) do
#     res = :file.truncate(fd)
#     Logger.info("| truncate | #{inspect fd} | result | #{inspect res} |")
#     res
#   end
#
#   def write(fd, blk) do
#     res = :file.write(fd, blk)
#     Logger.info("| write | #{inspect fd} | blk | #{:erlang.iolist_size blk} | result | #{inspect res} |")
#     res
#   end
#
#   def pread(fd, pos, size) do
#     res = :file.pread(fd, pos, size)
#     Logger.info("| pread | #{inspect fd} | pos | #{pos} | size | #{size} | result | #{
#       case res do
#         {:ok, data} -> "{:ok, #{:erlang.iolist_size(data)}}"
#         _ -> inspect(res)
#       end
#       } |")
#     res
#   end
#
# end
