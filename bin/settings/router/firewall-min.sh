#!/bin/bash
## Copyright © by Miles Bradley Huff from 2016 per the LGPL3 (the Third Lesser GNU Public License)
## Since theres already a stateful firewall set-up in the router, and since the
## port-forwarding/etc settings are probably just GUIs for iptables;  this
## "firewall" script is just going to be my own computers sysctl tweaks, edited to
## work on my router.
C=conf
E=echo
I=ipv4
N=net
P=/proc/sys
T=tcp_

$E 0 > $P/$N/$I/$C/all/arp_notify
$E 1 > $P/$N/$I/icmp_errors_use_inbound_ifaddr
$E 1 > $P/$N/$I/icmp_ignore_bogus_error_responses
$E 1 > $P/$N/$I/$C/all/log_martians
$E 0 > $P/vm/block_dump
$E 0 > $P/vm/oom_dump_tasks
$E 0 > $P/vm/panic_on_oom
$E 2 > $P/kernel/io_delay_type
$E 1 > $P/vm/compact_memory
$E 0 > $P/vm/compact_unevictable_allowed
$E 0 > $P/vm/memory_failure_early_kill
$E 0 > $P/vm/oom_kill_allocating_task
$E 8192 > $P/vm/admin_reserve_kbytes
$E 8192 > $P/vm/user_reserve_kbytes
$E 0 > $P/vm/overcommit_memory
$E 100 > $P/vm/overcommit_ratio
$E 66 > $P/vm/swappiness
$E 33 > $P/vm/vfs_cache_pressure
$E 1 > $P/vm/zone_reclaim_mode
$E 1 > $P/vm/memory_failure_recovery
$E 0 > $P/vm/legacy_va_layout
$E 0 > $P/vm/stat_interval
$E fq_codel > $P/$N/core/default_qdisc
$E 1 > $P/$N/$I/$C/all/forwarding
$E 1 > $P/$N/$I/cipso_cache_enable
$E 1 > $P/$N/$I/cipso_rbm_optfmt
$E 0 > $P/$N/$I/cipso_rbm_structvalid
$E 2 > $P/$N/$I/$C/all/app_solicit
$E 1 > $P/$N/$I/$C/all/arp_accept
$E 1 > $P/$N/$I/$C/all/arp_announce
$E 0 > $P/$N/$I/$C/all/arp_filter
$E 0 > $P/$N/$I/$C/all/arp_ignore
$E 2 > $P/$N/$I/$C/all/mcast_resolicit
$E 1 > $P/$N/$I/$C/all/proxy_arp
$E 1 > $P/$N/$I/$C/all/proxy_arp_pvlan
$E 1 > $P/$N/$I/fib_multipath_use_neigh
$E 1 > $P/$N/$I/${T}window_scaling
$E 1 > $P/$N/$I/${T}moderate_rcvbuf
$E 256960 > $P/$N/core/rmem_default
$E 256960 > $P/$N/core/wmem_default
$E '4096 256960 6291456' > $P/$N/$I/${T}rmem
$E '4096 256960 4194304' > $P/$N/$I/${T}wmem
$E 0 > $P/$N/$I/${T}abort_on_overflow
$E 1 > $P/$N/$I/${T}autocorking
$E 1 > $P/$N/$I/ip_early_demux
$E cubic > $P/$N/$I/${T}congestion_control
$E 2 > $P/$N/$I/${T}ecn
$E 1 > $P/$N/$I/${T}ecn_fallback
$E 0 > $P/$N/$I/${T}timestamps
$E 1 > $P/$N/$I/${T}no_metrics_save
$E 0 > $P/$N/$I/${T}slow_start_after_idle
$E 1539 > $P/$N/$I/${T}fastopen
$E 0 > $P/$N/$I/${T}low_latency
$E 1 > $P/$N/$I/${T}thin_linear_timeouts
$E 1 > $P/$N/$I/${T}thin_dupack
$E 1 > $P/$N/$I/$C/all/promote_secondaries
$E 3 > $P/$N/$I/${T}early_retrans
$E 1 > $P/$N/$I/${T}frto
$E 1 > $P/$N/$I/${T}recovery
$E 1 > $P/$N/$I/ip_dynaddr
$E 1 > $P/$N/$I/ip_nonlocal_bind
$E 1 > $P/$N/$I/${T}l3mdev_accept
$E 1 > $P/$N/$I/${T}mtu_probing
$E 1 > $P/$N/$I/${T}retrans_collapse
$E 0 > $P/$N/$I/${T}stdurg
$E 1 > $P/$N/$I/${T}workaround_signed_windows
$E 1 > $P/$N/$I/${T}sack
$E 1 > $P/$N/$I/${T}dsack
$E 1 > $P/$N/$I/${T}fack
$E 1 > $P/$N/$I/${T}tw_reuse
$E 0 > $P/$N/$I/${T}tw_recycle
$E 1 > $P/$N/ipv6/$C/all/disable_ipv6
$E 1 > $P/kernel/dmesg_restrict
$E 1 > $P/kernel/kptr_restrict
$E 0 > $P/kernel/yama/ptrace_scope
$E 0 > $P/$N/core/bpf_jit_enable
$E 1 > $P/$N/$I/$C/all/accept_redirects
$E 1 > $P/$N/ipv6/$C/all/accept_redirects
$E 1 > $P/$N/$I/$C/all/accept_source_route
$E 1 > $P/$N/ipv6/$C/all/accept_source_route
$E 1 > $P/$N/$I/$C/all/send_redirects
$E 1 > $P/$N/$I/$C/all/secure_redirects
$E 2 > $P/$N/$I/$C/all/rp_filter
$E 1 > $P/$N/$I/$C/all/shared_media
$E 1 > $P/$N/$I/$C/all/route_localnet
$E 1 > $P/$N/$I/$C/all/accept_local
$E 0 > $P/$N/$I/$C/all/bootp_relay
$E 1 > $P/$N/$I/$C/all/drop_unicast_in_l2_multicast
$E 1 > $P/$N/$I/$C/all/rp_filter
$E 1 > $P/$N/$I/$C/all/secure_redirects
$E 1 > $P/$N/$I/fwmark_reflect
$E 0 > $P/$N/$I/icmp_echo_ignore_all
$E 0 > $P/$N/$I/icmp_echo_ignore_broadcasts
$E 250 > $P/$N/$I/icmp_ratelimit
$E 250 > $P/$N/$I/${T}challenge_ack_limit
$E 350233 > $P/$N/$I/icmp_ratemask
$E 1200 > $P/$N/$I/${T}keepalive_time
$E 4 > $P/$N/$I/${T}keepalive_probes
$E 30 > $P/$N/$I/${T}keepalive_intvl
$E 180000 > $P/$N/$I/${T}max_tw_buckets
$E 500 > $P/$N/$I/${T}invalid_ratelimit
$E 0 > $P/$N/$I/ip_no_pmtu_disc
$E 0 > $P/$N/$I/ip_forward_use_pmtu
$E 4096 > $P/$N/$I/${T}max_orphans
$E 30 > $P/$N/$I/${T}fin_timeout
$E 1 > $P/$N/$I/${T}rfc1337
$E 1 > $P/$N/$I/${T}syncookies
$E 2 > $P/$N/$I/${T}syn_retries
$E 2 > $P/$N/$I/${T}synack_retries
$E 65536 > $P/vm/mmap_min_addr
